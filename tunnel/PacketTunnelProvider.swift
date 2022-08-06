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
import ProxyServer
import func os.os_log

class PacketTunnelProvider: NEPacketTunnelProvider {
    private weak var timeoutTimer: Timer?
    private var session: NWUDPSession?
    private var observer: AnyObject?
    private let logger: Logger
    private let proxyServer: ProxyServer
    
    private let proxyIP = "192.168.1.225"
    private let proxyPort = 8080
    private let options = ProxyServerOptions(ipv4Address: "192.168.1.225", ipv4Port: 8080, ipv6Address: "2603:7000:9200:1a31:846:8a47:6fe:f009", ipv6Port: 8080)
    
    override init() {
        LoggingSystem.bootstrap(LoggingOSLog.init)
        self.logger = Logger(label: "com.strangeindustries.slowdown.PacketTunnelProvider")
        
        
        self.proxyServer = ProxyServer(logger: self.logger, options: self.options)
    }
    
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        self.logger.info("tunnel started.")
        self.timeoutTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) {_ in
            completionHandler(NEVPNError(.connectionFailed))
        }
        self.proxyServer.start()
        
        let settings = self.initTunnelSettings(proxyHost: proxyIP, proxyPort: proxyPort)
        
        self.setTunnelNetworkSettings(settings) { error in
            completionHandler(error)
            let endpoint = NWHostEndpoint(hostname: self.options.ipv4Address, port: String(self.options.ipv4Port))
            self.session = self.createUDPSession(to: endpoint, from: nil)
            self.observer = self.session?.observe(\.state, options: [.new]) { session, _ in
                if session.state == .ready {
                    // The session is ready to exchange UDP datagrams with the server
                    self.readPackets()
                }
            }
        }
    }
    
    private func readPackets() {
        self.logger.info("reading packets")
        self.packetFlow.readPacketObjects {[weak self] packets in
            guard let strongSelf = self else { return }
            for packet in packets {
                //                strongSelf.logger.info("Sending packet: \(packet.data.base64EncodedString())")
                strongSelf.session?.writeDatagram(packet.data) { error in
                }
            }
            strongSelf.readPackets()
        }
    }
    
    private func initTunnelSettings(proxyHost: String, proxyPort: Int) -> NEPacketTunnelNetworkSettings {
        let settings: NEPacketTunnelNetworkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "127.0.0.1")
        let ipv6Settings: NEIPv6Settings = NEIPv6Settings(
            addresses: ["::1"],
            networkPrefixLengths: [128]
        )
        ipv6Settings.includedRoutes = [NEIPv6Route.default()]
        settings.ipv6Settings = ipv6Settings
        let ipv4Settings: NEIPv4Settings = NEIPv4Settings(
            addresses: [settings.tunnelRemoteAddress],
            subnetMasks: ["255.255.255.255"]
        )
        ipv4Settings.includedRoutes = [NEIPv4Route.default()]
        ipv4Settings.excludedRoutes = [
            NEIPv4Route(destinationAddress: "192.168.0.0", subnetMask: "255.255.0.0"),
            NEIPv4Route(destinationAddress: "10.0.0.0", subnetMask: "255.0.0.0"),
            NEIPv4Route(destinationAddress: "172.16.0.0", subnetMask: "255.240.0.0")
        ]
        settings.ipv4Settings = ipv4Settings
        settings.mtu = 1500
        return settings
    }
    
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        self.logger.info("tunnel stopped")
        // Add code here to start the process of stopping the tunnel.
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
}




