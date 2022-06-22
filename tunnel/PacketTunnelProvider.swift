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


class PacketTunnelProvider: NEPacketTunnelProvider {

    private weak var timeoutTimer: Timer?
    
    private var connection: NWTCPConnection?
    
    private var logger = Logger(label: "com.strangeindustries.slowdown.tunnel")
    
    private var proxyServer: ProxyServer
    
    override init() {
        LoggingSystem.bootstrap(LoggingOSLog.init)
        self.proxyServer = ProxyServer(logger: self.logger)
    }

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        self.logger.info("tunnel started.")
        self.timeoutTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) {_ in
            completionHandler(NEVPNError(.connectionFailed))
        }
        
        let proxyIP = "127.0.0.1"
        let proxyPort = 8080
        
        self.proxyServer.start()
        
        let settings = self.initTunnelSettings(proxyHost: proxyIP, proxyPort: proxyPort)
        
        setTunnelNetworkSettings(settings) { error in
            completionHandler(error)
            let endpoint = NWHostEndpoint(hostname: proxyIP, port: String(proxyPort))
            self.connection = self.createTCPConnection(to: endpoint, enableTLS: false, tlsParameters: nil, delegate: nil)
            self.readPackets()
        }
        
    }
    
    private func readPackets() {
        self.packetFlow.readPackets {[weak self] (packets, protocols) in
            guard let strongSelf = self else { return }
            for packet in packets {
                strongSelf.connection?.write(packet, completionHandler: { (error) in
                })
            }
            
            // Repeat
            strongSelf.readPackets()
        }
    }
    
    private func initTunnelSettings(proxyHost: String, proxyPort: Int) -> NEPacketTunnelNetworkSettings {
        let settings: NEPacketTunnelNetworkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "127.0.0.1")

        /* proxy settings */
        let proxySettings: NEProxySettings = NEProxySettings()
        proxySettings.httpsServer = NEProxyServer(
            address: proxyHost,
            port: proxyPort
        )
        proxySettings.autoProxyConfigurationEnabled = false
        proxySettings.httpEnabled = true
        proxySettings.httpsEnabled = true
        proxySettings.excludeSimpleHostnames = true
        proxySettings.exceptionList = [
            "192.168.0.0/16",
            "10.0.0.0/8",
            "172.16.0.0/12",
            "127.0.0.1",
            "localhost",
            "*.local"
        ]
        settings.proxySettings = proxySettings
        
        /* ipv4 settings */
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
        
        /* MTU */
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




