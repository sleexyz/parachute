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


public struct ProxyServerOptions {
    public let ipv4Address: String
    public let ipv4Port: Int
    public let ipv6Address: String
    public let ipv6Port: Int
    public init(ipv4Address: String, ipv4Port: Int, ipv6Address: String, ipv6Port: Int) {
        self.ipv4Address = ipv4Address
        self.ipv4Port = ipv4Port
        self.ipv6Address = ipv6Address
        self.ipv6Port = ipv6Port
    }
}

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
        let protocolNumber = self.protocolNumber(for: inputData) === AF_INET6 as NSNumber ? "ipv6" : "ipv4"
        logger.info("\(protocolNumber) packet received: \(inputData.base64EncodedString())")
    }
    
    public func channelReadComplete(context: ChannelHandlerContext) {
        context.flush()
    }
    
    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        self.logger.error("error: \(error)")
        context.close(promise: nil)
    }
    
    private func protocolNumber(for packet: Data) -> NSNumber {
        guard !packet.isEmpty else {
            return AF_INET as NSNumber
        }

        // 'packet' contains the decrypted incoming IP packet data
        // The first 4 bits identify the IP version
        let ipVersion = (packet[0] & 0xf0) >> 4
        return (ipVersion == 6) ? AF_INET6 as NSNumber : AF_INET as NSNumber
    }
    
}

public class ProxyServer {
    private var logger: Logger
    private var group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    private var bootstrap: DatagramBootstrap
    private var options: ProxyServerOptions
    
    public init(logger: Logger, options: ProxyServerOptions) {
        self.logger = logger
        self.options = options
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
        self.bootstrap.bind(to: try! SocketAddress(ipAddress: options.ipv4Address, port: options.ipv4Port)).whenComplete { result in
            // Need to create this here for thread-safety purposes
            let logger = Logger(label: "com.strangeindustries.slowdown.ProxyServer")
            switch result {
            case .success(let channel):
                logger.info("Listening on \(String(describing: channel.localAddress))")
            case .failure(let error):
                logger.error("Failed to bind \(self.options.ipv6Address):\(self.options.ipv6Port), \(String(describing: error))")
            }
        }

        self.bootstrap.bind(to: try! SocketAddress(ipAddress: options.ipv6Address, port: options.ipv6Port)).whenComplete { result in
            // Need to create this here for thread-safety purposes
            let logger = Logger(label: "com.strangeindustries.slowdown.ProxyServer")
            switch result {
            case .success(let channel):
                logger.info("Listening on \(String(describing: channel.localAddress))")
            case .failure(let error):
                logger.error("Failed to bind \(self.options.ipv6Address):\(self.options.ipv6Port), \(String(describing: error))")
            }
        }
    }
}
