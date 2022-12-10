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
import Ffi

public struct ProxyServerOptions {
    public let ipv4Address: String
    public let ipv4Port: Int
    public init(ipv4Address: String, ipv4Port: Int) {
        self.ipv4Address = ipv4Address
        self.ipv4Port = ipv4Port
    }
    static let localServer = ProxyServerOptions(ipv4Address: "127.0.0.1", ipv4Port: 8080)
    
    static let debugDataServer = ProxyServerOptions(ipv4Address: "192.168.1.225", ipv4Port: 8080)
    static let debugControlServer = ProxyServerOptions(ipv4Address: "192.168.1.225", ipv4Port: 8083)
}

class PacketTunnelProvider: NEPacketTunnelProvider {
    private weak var timeoutTimer: Timer?
    private var session: NWUDPSession?
    private var observer: AnyObject?
    private let queue = DispatchQueue(label: "com.strangeindustries.slowdown.PacketTunnelProvider")
    private let logger: Logger
    
    private var cheatCompletion: DispatchWorkItem?
    private var options: ProxyServerOptions = .localServer
    
    private var proxy: FfiProxyProtocol?
    
    private var cheat: Bool {
        return cheatCompletion != nil
    };
    
    override init() {
        LoggingSystem.bootstrap(LoggingOSLog.init)
        let logger = Logger(label: "com.strangeindustries.slowdown.PacketTunnelProvider")
        logger.info("go max procs: \(Ffi.FfiMaxProcs(1))")
        logger.info("go memory limit: \(Ffi.FfiSetMemoryLimit(20<<20))")
        logger.info("go gc percent: \(Ffi.FfiSetGCPercent(50))")
        self.logger = logger
    }
    
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        let debug = options?["debug"] != nil  ? (options?["debug"]! as! NSNumber).boolValue : false
        
        self.logger.info("starting tunnel")
        self.timeoutTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) {_ in
            completionHandler(NEVPNError(.connectionFailed))
        }
        
        if (!debug) {
            self.proxy = Ffi.FfiInit()!
            self.logger.info("starting server")
            DispatchQueue.global(qos: .background).async {
                self.proxy!.start(self.options.ipv4Port)
            }
            self.logger.info("server started")
        } else {
            self.proxy = Ffi.FfiInitDebug("\(ProxyServerOptions.debugControlServer.ipv4Address):\(ProxyServerOptions.debugControlServer.ipv4Port)")!
            self.logger.info("server started")
        }
        
        self.options = debug ? .debugDataServer : .localServer
        
        let settings = self.initTunnelSettings(proxyHost: self.options.ipv4Address, proxyPort: self.options.ipv4Port)
        
        self.setTunnelNetworkSettings(settings) { error in
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
        settings.dnsSettings = NEDNSSettings(servers: ["8.8.8.8"])
        return settings
    }
    
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        self.logger.info("tunnel stopped")
        // Add code here to start the process of stopping the tunnel.
        self.proxy!.close()
        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        guard let messageString = NSString(data: messageData, encoding: String.Encoding.utf8.rawValue) else {
            completionHandler?(nil)
            return
        }
        
        if messageString == "cheat" {
            self.startCheat()
        }
        
        // Add code here to handle the message.
        let responseData = "ack".data(using: String.Encoding.utf8)
        completionHandler?(responseData)
    }
    
    func startCheat() {
        self.logger.info("cheat")
        self.proxy!.setLatency(0)
        
        self.cheatCompletion?.cancel()
        self.cheatCompletion = DispatchWorkItem {
            self.proxy!.setLatency(40)
            self.logger.info("cheat end")
            self.cheatCompletion = nil
        }
        self.queue.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(60), execute: cheatCompletion!)

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




