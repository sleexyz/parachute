//
//  ProxyServer.swift
//  tunnel
//
//  Created by Sean Lee on 7/14/22.
//

import Foundation
import NIO
import Dispatch
import Logging


class ProxyHandler : ChannelInboundHandler {
    public typealias InboundIn = AddressedEnvelope<ByteBuffer>
    public typealias OutboundOut = AddressedEnvelope<ByteBuffer>
    
    private var logger: Logger;
    
    init(logger: Logger) {
        self.logger = logger;
    }
    
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let inputEnvelope = unwrapInboundIn(data)
        let inputData = Data(inputEnvelope.data.readableBytesView)
        logger.info("packet received: \(inputData.base64EncodedString())")
    }
    
    public func channelReadComplete(context: ChannelHandlerContext) {
        context.flush()
    }
    
    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        self.logger.error("error: \(error)")
        context.close(promise: nil)
    }
    
}

public class ProxyServer {
    private var logger: Logger
    private var group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    private var bootstrap: DatagramBootstrap
    
    public init(logger: Logger) {
        self.logger = logger
        // Bootstraps listening channels
        self.bootstrap = DatagramBootstrap(group: group)
            .channelOption(ChannelOptions.socket(SOL_SOCKET, SO_REUSEADDR), value: 1)
            .channelInitializer { channel in
                channel.pipeline.addHandler(ProxyHandler(logger: Logger(label: "com.strangeindustries.slowdown.ProxyHandler")))
            }
        logger.info("Initialized ProxyServer.")
    }
    
    public func start() {
        logger.info("Starting ProxyServer.")
        self.bootstrap.bind(to: try! SocketAddress(ipAddress: "127.0.0.1", port: 8080)).whenComplete { result in
            // Need to create this here for thread-safety purposes
            let logger = Logger(label: "com.strangeindustries.slowdown.ProxyServer")
            switch result {
            case .success(let channel):
                logger.info("Listening on \(String(describing: channel.localAddress))")
            case .failure(let error):
                logger.error("Failed to bind 127.0.0.1:8080 \(String(describing: error))")
            }
        }

        self.bootstrap.bind(to: try! SocketAddress(ipAddress: "::1", port: 8080)).whenComplete { result in
            // Need to create this here for thread-safety purposes
            let logger = Logger(label: "com.strangeindustries.slowdown.ProxyServer")
            switch result {
            case .success(let channel):
                logger.info("Listening on \(String(describing: channel.localAddress))")
            case .failure(let error):
                logger.error("Failed to bind [::1]:8080, \(String(describing: error))")
            }
        }
    }
}
