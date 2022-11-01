//
//  PacketTunnelProvider.swift
//  tunnel
//
//  Created by Sean Lee on 4/28/22.
//

import Foundation
import NetworkExtension
import Logging
import LoggingOSLog
import func os.os_log
import UIKit
import Singleton

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

class PacketTunnelProvider: NEPacketTunnelProvider {
    private weak var timeoutTimer: Timer?
    private var session: NWUDPSession?
    private var observer: AnyObject?
    private let queue = DispatchQueue(label: "com.strangeindustries.slowdown.PacketTunnelProvider")
    private let logger: Logger
//    private let proxyServer: ProxyServer
    
    private let options = ProxyServerOptions(ipv4Address: "127.0.0.1", ipv4Port: 8080, ipv6Address: "::1", ipv6Port: 8080)
//    private let options = ProxyServerOptions(ipv4Address: "192.168.1.225", ipv4Port: 8080, ipv6Address: "2603:7000:9200:1a31:846:8a47:6fe:f009", ipv6Port: 8080)
    
    override init() {
        LoggingSystem.bootstrap(LoggingOSLog.init)
        self.logger = Logger(label: "com.strangeindustries.slowdown.PacketTunnelProvider")
        logger.info("go max procs: \(Singleton.SingletonMaxProcs(1))")
        logger.info("go memory limit: \(Singleton.SingletonSetMemoryLimit(5*1<<20))")
        logger.info("go gc percent: \(Singleton.SingletonSetGCPercent(20))")
        logger.info("go max procs: \(Singleton.SingletonMaxProcs(1))")
        logger.info("go memory limit: \(Singleton.SingletonSetMemoryLimit(5*1<<20))")
        logger.info("go gc percent: \(Singleton.SingletonSetGCPercent(20))")
//        self.proxyServer = ProxyServer(logger: self.logger, options: self.options)
    }
    
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        self.logger.info("starting tunnel")
        self.timeoutTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) {_ in
            completionHandler(NEVPNError(.connectionFailed))
        }
        
        if self.options.ipv6Address == "127.0.0.0.1" {
            self.logger.info("starting server")
            DispatchQueue.global(qos: .background).async {
                Singleton.SingletonStart(self.options.ipv4Port)
            }
            self.logger.info("server started")
        }
        
//        self.proxyServer.start()
        
        let settings = self.initTunnelSettings(proxyHost: self.options.ipv4Address, proxyPort: self.options.ipv4Port)
        
        self.setTunnelNetworkSettings(settings) { error in
            completionHandler(error)
            let endpoint = NWHostEndpoint(hostname: self.options.ipv4Address, port: String(self.options.ipv4Port))
            self.session = self.createUDPSession(to: endpoint, from: nil)
            self.observer = self.session?.observe(\.state, options: [.new]) { session, _ in
                if session.state == .ready {
                    session.setReadHandler({ [weak self] datagrams, error in
                        guard let self = self else { return }
                        self.queue.async {
                            for datagram in datagrams ?? [] {
                                let protocolNumber = self.protocolNumber(for: datagram) === AF_INET6 as NSNumber ? "ipv6" : "ipv4"
                                self.logger.info("Inbound \(protocolNumber) packet: \(datagram.base64EncodedData())")
                                self.packetFlow.writePackets([datagram], withProtocols: [self.protocolNumber(for: datagram)])
                            }
                        }
                    }, maxDatagrams: Int.max)
                    self.logger.info("tunnel started")
                    
                    // The session is ready to exchange UDP datagrams with the server
                    self.readOutboundPackets()
                }
            }
        }
    }
    
    private func readOutboundPackets() {
        self.packetFlow.readPacketObjects {[weak self] packets in
            guard let self = self else { return }
            for packet in packets {
                let protocolNumber = self.protocolNumber(for: packet.data) === AF_INET6 as NSNumber ? "ipv6" : "ipv4"
                self.logger.info("Outbound \(protocolNumber) packet: \(packet.data.base64EncodedString())")
                self.session?.writeDatagram(packet.data) { error in
                    guard let error = error else { return }
                    self.logger.error("Error: \(String(describing: error))")
                }
            }
            self.queue.async {
                self.readOutboundPackets()
            }
        }
    }
    
    private func initTunnelSettings(proxyHost: String, proxyPort: Int) -> NEPacketTunnelNetworkSettings {
        let settings: NEPacketTunnelNetworkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: self.options.ipv4Address)
        let ipv4Settings: NEIPv4Settings = NEIPv4Settings(
            addresses: ["10.0.0.8"],
            subnetMasks: ["255.255.255.0"]
        )
        ipv4Settings.includedRoutes = [NEIPv4Route.default()]
        ipv4Settings.excludedRoutes = [
            NEIPv4Route(destinationAddress: "192.168.0.0", subnetMask: "255.255.0.0"),
            NEIPv4Route(destinationAddress: "10.0.0.0", subnetMask: "255.0.0.0"),
            NEIPv4Route(destinationAddress: "172.16.0.0", subnetMask: "255.240.0.0")
        ]
        settings.ipv4Settings = ipv4Settings
        let ipv6Settings: NEIPv6Settings = NEIPv6Settings(
            addresses: ["fd00::2"],
            networkPrefixLengths: [64]
        )
        ipv6Settings.includedRoutes = [NEIPv6Route.default()]
        settings.ipv6Settings = ipv6Settings
        settings.mtu = 1500
        settings.dnsSettings = NEDNSSettings(servers: ["8.8.8.8"])
        return settings
    }
    
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        self.logger.info("tunnel stopped")
        // Add code here to start the process of stopping the tunnel.
        Singleton.SingletonClose()
        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Add code here to handle the message.
        if let handler = completionHandler {
            handler(messageData)
        }
    }
    
    override func sleep(completionHandler: @escaping () -> Void) {
        // Add code here to get ready to sleep.
        completionHandler()
    }
    
    override func wake() {
        // Add code here to wake up.
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




