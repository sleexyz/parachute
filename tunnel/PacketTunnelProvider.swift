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
import UIKit
import ProxyService
import Server
            

public struct ProxyServerOptions {
    public let ipv4Address: String
    public let ipv4Port: Int
    public init(ipv4Address: String, ipv4Port: Int) {
        self.ipv4Address = ipv4Address
        self.ipv4Port = ipv4Port
    }
    static let localServer = ProxyServerOptions(ipv4Address: "127.0.0.1", ipv4Port: 8080)
    
    static let debugDataServer = ProxyServerOptions(ipv4Address: "192.168.1.225", ipv4Port: 8080)
}

class PacketTunnelProvider: NEPacketTunnelProvider {
    private weak var timeoutTimer: Timer?
    private var session: NWUDPSession?
    private var observer: AnyObject?
    private let queue = DispatchQueue(label: "industries.strange.slowdown.tunnel.PacketTunnelProvider")
    private let logger: Logger
    
    private var options: ProxyServerOptions = .localServer
    
    private var server: Server?
    
    override init() {
        LoggingSystem.bootstrap(LoggingOSLog.init)
        let logger = Logger(label: "industries.strange.slowdown.tunnel.PacketTunnelProvider")
        self.logger = logger
    }
    
    private static func fileUrl() throws -> URL {
        guard let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.industries.strange.slowdown") else {
            fatalError("could not get shared app group directory.")
        }
        return groupURL.appendingPathComponent("settings.data")
    }
    
    func loadSettingsData() throws -> Data {
        let file = try FileHandle(forReadingFrom: PacketTunnelProvider.fileUrl())
        return file.availableData
    }
    
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        do {
            let settingsData = try loadSettingsData()
            let settings = try Proxyservice_Settings(serializedData: settingsData)
            
            self.logger.info("starting tunnel")
            self.timeoutTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) {_ in
                completionHandler(NEVPNError(.connectionFailed))
            }
            
            self.server = Server.InitTunnelServer(settings: settings)
            
            self.logger.info("starting server")
            DispatchQueue.global(qos: .background).async {
                self.server!.startProxy(port: 8080, settingsData: settingsData)
            }
            self.logger.info("server started")
            
            self.options = settings.debug ? .debugDataServer : .localServer
            
            let tunnelSettings = self.initTunnelSettings(proxyHost: self.options.ipv4Address, proxyPort: self.options.ipv4Port)
            
            self.setTunnelNetworkSettings(tunnelSettings) { error in
                completionHandler(error)
                let endpoint = NWHostEndpoint(hostname: self.options.ipv4Address, port: String(self.options.ipv4Port))
                self.session = self.createUDPSession(to: endpoint, from: nil)
                self.observer = self.session?.observe(\.state, options: [.new]) { session, _ in
                    if session.state == .ready {
                        session.setReadHandler({ [weak self] datagrams, error in
                            guard let self = self else { return }
                            for datagram in datagrams ?? [] {
                                self.packetFlow.writePackets([datagram], withProtocols: [self.protocolNumber(for: datagram)])
                            }
                        }, maxDatagrams: Int.max)
                        self.logger.info("tunnel started")
                        
                        // The session is ready to exchange UDP datagrams with the server
                        self.readOutboundPackets()
                    }
                }
            }
        } catch {
            fatalError("Encountered error")
        }
    }
    
    private func readOutboundPackets() {
        self.packetFlow.readPacketObjects {[weak self] packets in
            guard let self = self else { return }
            for packet in packets {
                //                let protocolNumber = self.protocolNumber(for: packet.data) === AF_INET6 as NSNumber ? "ipv6" : "ipv4"
                //                self.logger.info("Outbound \(protocolNumber) packet: \(packet.data.base64EncodedString())")
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
//        settings.dnsSettings = NEDNSSettings(servers: ["8.8.8.8"])
        settings.dnsSettings = NEDNSSettings(servers: ["10.0.0.9"])
        settings.dnsSettings?.matchDomains = [""] // All dns requests go through tunnel
        return settings
    }
    
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        self.logger.info("tunnel stopped")
        // Add code here to start the process of stopping the tunnel.
        self.server!.close()
        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        do {
            let response = try server?.rpc(input: messageData)
            completionHandler?(response)
        } catch {
            self.logger.error("RPC error: \(error.localizedDescription)")
            completionHandler?(nil)
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




