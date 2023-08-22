//
//  PacketTunnelProvider.swift
//  tunnel
//
//  Created by Sean Lee on 4/28/22.
//

import Foundation
import NetworkExtension
import Logging
// import LoggingOSLog
import UIKit
import ProxyService
import Server
import Firebase
import UserNotifications
import Common
import Ffi

enum ProxyError: Error {
    case pauseError
}

class PacketTunnelProvider: NEPacketTunnelProvider {
    private let logger: Logger = {
        // LoggingSystem.bootstrap(LoggingOSLog.init)
        return Logger(label: "industries.strange.slowdown.tunnel.PacketTunnelProvider")
    }()
    private weak var timeoutTimer: Timer?
    private var observer: AnyObject?
    private let queue = DispatchQueue(label: "industries.strange.slowdown.tunnel.PacketTunnelProvider")
    private var server: Server?
    
    private var tunConn: TunConn?
    private var deviceCallbacks = DeviceCallbacks()
    
    override init() {
        if Env.value == .prod {
            FirebaseApp.configure()
        }
        super.init()
        self.tunConn = TunConn {
            return self.packetFlow
        }
        logger.info("init PacketTunnelProvider")
    }
    
    func loadSettingsData(options: [String: NSObject]?) throws -> Data {
        if let obj: NSObject = options?["settingsOverride"] {
            logger.info("using settingsOverride")
            return (obj as! NSData) as Data
        }
        return try SettingsHelper.loadSettingsData()
    }
    
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        do {
            self.logger.info("starting tunnel")
            self.timeoutTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) {_ in
                completionHandler(NEVPNError(.connectionFailed))
            }
            
            self.logger.info("loading settings")
            let settingsData = try loadSettingsData(options: options)
            let settings = try Proxyservice_Settings(serializedData: settingsData)
            self.logger.info("loading settings -- done")
            
            self.logger.info("starting server")
            self.server = Server.InitTunnelServer(settings: settings, deviceCallbacks: deviceCallbacks)
            self.server!.startDirectProxyConnection(tunConn: self.tunConn!, settingsData: settingsData)
            self.logger.info("starting server -- done")
            
            self.setTunnelNetworkSettings(PacketTunnelProvider.tunnelSettings) { error in
                completionHandler(error)
                self.readOutboundPackets()
            }
            self.logger.info("starting tunnel -- done")
        } catch let error {
            if Env.value == .prod {
                Crashlytics.crashlytics().record(error: error)
            }
            completionHandler(NEVPNError(.connectionFailed))
//            fatalError("Encountered error while starting up")
        }
    }
    
    private func readOutboundPackets() {
        self.packetFlow.readPackets {[weak self] packets, _ in
            guard let self = self else { return }
            for packet in packets {
                self.server!.writeOutboundPacket(packet)
            }
            // Putting the self-call in a Task seems to reduce crashes.
//            self.queue.asyncAfter(deadline: .now().advanced(by: .milliseconds(1)) ){
            self.queue.async {
                self.readOutboundPackets()
            }
        }
    }
    
    
    private static var tunnelSettings: NEPacketTunnelNetworkSettings {
        let settings: NEPacketTunnelNetworkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "127.0.0.1")
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
//        settings.dnsSettings = NEDNSSettings(servers: ["8.8.8.8"])
        settings.dnsSettings = NEDNSSettings(servers: ["10.0.0.9"])
        settings.dnsSettings?.matchDomains = [""] // All dns requests go through tunnel
        return settings
    }
    
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        self.logger.info("tunnel stopped")
        self.server!.close()
        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data) async -> Data? {
        guard let server = server else {
            fatalError("server not initialized yet")
        }
        return server.rpc(input: messageData)
    }
    
    static func protocolNumber(for packet: Data) -> NSNumber {
        guard !packet.isEmpty else {
            return AF_INET as NSNumber
        }
        
        // 'packet' contains the decrypted incoming IP packet data
        // The first 4 bits identify the IP version
        let ipVersion = (packet[0] & 0xf0) >> 4
        return (ipVersion == 6) ? AF_INET6 as NSNumber : AF_INET as NSNumber
    }
}




