import Foundation
import NIO
import NIOHTTP1
import Logging

final class HttpHandler : ChannelDuplexHandler {
    private var state: State
    
    private var logger: Logger
    
    private var bufferedBody: ByteBuffer?
    private var bufferedEnd: HTTPHeaders?
    
    
    init(logger: Logger) {
        self.state = State.idle
        self.logger = logger
    }
    
    enum State {
        case idle
        case pendingConnection(head: HTTPRequestHead)
        case connected
    }
    
    enum ConnectError: Error {
        case invalidURL
        case wrongScheme
        case wrongHost
    }
    
    // InboundIn => InboundOut => (Server)
    //                                ||
    //                                ||
    //                                \/
    // OutboundOut <= OutboundIn <= (Proxy)
    
    typealias InboundIn = HTTPServerRequestPart
    typealias InboundOut = HTTPClientRequestPart
    
    typealias OutboundIn = HTTPClientResponsePart
    typealias OutboundOut = HTTPServerResponsePart
    
    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        switch self.unwrapOutboundIn(data) { // HTTPClientResponsePart
        case .head(let head):
            self.logger.info("writing head: \(head)")
            context.write(self.wrapOutboundOut(.head(head)), promise: nil)
        case .body(let body):
            self.logger.info("writing body: \(body)")
            context.write(self.wrapOutboundOut(.body(.byteBuffer(body))), promise: nil)
        case .end(let trailers):
            self.logger.info("writing trailers: \(String(describing: trailers))")
            context.write(self.wrapOutboundOut(.end(trailers)), promise: nil)
        }
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        guard case .head(let head) = self.unwrapInboundIn(data) else {
            let unwrapped = self.unwrapInboundIn(data)
            
            switch unwrapped {
            case .body(let buffer):
                switch state {
                case .connected:
                    context.fireChannelRead(self.wrapInboundOut(.body(.byteBuffer(buffer))))
                case .pendingConnection(_):
                    self.logger.info("Buffering body")
                    self.bufferedBody = buffer
                default:
                    // shouldnt happen
                    break
                }
                
            case .end(let headers):
                switch state {
                case .connected:
                    context.fireChannelRead(self.wrapInboundOut(.end(headers)))
                case .pendingConnection(_):
                    self.logger.info("Buffering end")
                    self.bufferedEnd = headers
                default:
                    // shouldnt happen
                    break
                }
                
            case .head(_):
                assertionFailure("Not possible")
                break
            }
            return
        }
        
        self.logger.info("Connecting to URI: \(head.uri)")
        
        guard let parsedUrl = URL(string: head.uri) else {
            context.fireErrorCaught(ConnectError.invalidURL)
            return
        }
        self.logger.info("Parsed scheme: \(parsedUrl.scheme ?? "no scheme")")
        
        guard parsedUrl.scheme == "http" else {
            context.fireErrorCaught(ConnectError.wrongScheme)
            return
        }
        
        guard let host = head.headers.first(name: "Host"), host == parsedUrl.host else {
            self.logger.info("Wrong host")
            context.fireErrorCaught(ConnectError.wrongHost)
            return
        }
        
        switch state {
        case .idle:
            state = .pendingConnection(head: head)
            connectTo(host: host, port: 80, context: context)
        case .pendingConnection(_):
            self.logger.info("Logic error fireChannelRead with incorrect state")
            
        case .connected:
            context.fireChannelRead(self.wrapInboundOut(.head(head)))
        }
    }
    
    private func connectTo(host: String, port: Int, context: ChannelHandlerContext) {
        let channelFuture = ClientBootstrap(group: context.eventLoop)
            .channelInitializer { channel in
                channel.pipeline.addHandler(HTTPRequestEncoder())
                    .flatMap {
                        channel.pipeline.addHandler(ByteToMessageHandler(HTTPResponseDecoder(leftOverBytesStrategy: .forwardBytes)))
                    }
            }
            .connect(host: host, port: port)
        
        channelFuture.whenSuccess { channel in
            self.connectSucceeded(channel: channel, context: context)
        }
        channelFuture.whenFailure { error in
            self.connectFailed(error: error, context: context)
        }
    }
    
    private func connectSucceeded(channel: Channel, context: ChannelHandlerContext) {
        self.logger.info("Connect succeeded")
        self.glue(channel, context: context)
    }
    
    private func connectFailed(error: Error, context: ChannelHandlerContext) {
        self.logger.info("Connect failed: \(error)")
        context.fireErrorCaught(error)
    }
    
    private func glue(_ peerChannel: Channel, context: ChannelHandlerContext) {
        // Now we need to glue our channel and the peer channel together.
        let (localGlue, peerGlue) = GlueHandler.matchedPair()
        context.channel.pipeline.addHandler(localGlue).and(peerChannel.pipeline.addHandler(peerGlue)).whenComplete { result in
            switch result {
            case .success(_):
                if case let .pendingConnection(head) = self.state {
                    self.state = .connected
                    
                    context.fireChannelRead(self.wrapInboundOut(.head(head)))
                    
                    if let bufferedBody = self.bufferedBody {
                        context.fireChannelRead(self.wrapInboundOut(.body(.byteBuffer(bufferedBody))))
                        self.bufferedBody = nil
                    }
                    
                    if let bufferedEnd = self.bufferedEnd {
                        context.fireChannelRead(self.wrapInboundOut(.end(bufferedEnd)))
                        self.bufferedEnd = nil
                    }
                    
                    context.fireChannelReadComplete()
                }
            case .failure(_):
                // Close connected peer channel before closing our channel.
                peerChannel.close(mode: .all, promise: nil)
                context.close(promise: nil)
            }
        }
    }
}
