//
//  ProxyServer.swift
//  tunnel
//
//  Created by Sean Lee on 6/20/22.
//


import Foundation
import NIO
import NIOHTTP1
import Dispatch
import Logging



class ProxyServer {
    private var logger: Logger
    private var group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    private var bootstrap: ServerBootstrap
    
    init(logger: Logger) {
        self.logger = logger
        self.bootstrap = ServerBootstrap(group: group)
            .serverChannelOption(ChannelOptions.socket(SOL_SOCKET, SO_REUSEADDR), value: 1)
            .childChannelOption(ChannelOptions.socket(SOL_SOCKET, SO_REUSEADDR), value: 1)
            .childChannelInitializer { channel in
                channel.pipeline.addHandler(ByteToMessageHandler(HTTPRequestDecoder(leftOverBytesStrategy: .forwardBytes)))
                    .flatMap { channel.pipeline.addHandler(HTTPResponseEncoder()) }
                    .flatMap { channel.pipeline.addHandler(ConnectHandler(logger: Logger(label: "com.strangeindustries.slowdown.ConnectHandler"))) }
            }
        logger.info("Initialized proxy server.")
    }
    
    func start() {

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
