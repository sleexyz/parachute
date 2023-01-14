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
import Firebase
import Ffi
import UserNotifications

class TunConn: NSObject, FfiCallbacksProtocol {
    var packetFlow: NEPacketTunnelFlow {
        return packetFlowGetter()
    }
    
    var packetFlowGetter: () -> NEPacketTunnelFlow
    
    init(packetFlowGetter: @escaping () -> NEPacketTunnelFlow) {
        self.packetFlowGetter = packetFlowGetter
    }
    
    func writeInboundPacket(_ data: Data?) {
        guard let data = data else {
            fatalError("data is nil")
        }
        self.packetFlow.writePackets([data], withProtocols: [PacketTunnelProvider.protocolNumber(for: data)])
    }
}

class Device: NSObject, FfiDeviceCallbacksProtocol {
    private let logger: Logger = Logger(label: "industries.strange.slowdown.tunnel.Device")
    private var notificationsEnabled: Bool = false
    
    override init() {
        super.init()
        Task {
            do {
                self.notificationsEnabled = try await enableNotifications()
                logger.info("notification status: \(notificationsEnabled)")
            } catch {
                logger.error("notifications not enabled")
            }
        }
    }
    
    func sendNotification(_ title: String?, message: String?) {
        guard let title = title else {
            fatalError("not title: \(title.debugDescription)")
        }
        guard let message = message else {
            fatalError("not message: \(message.debugDescription)")
        }
        logger.info("Got message to send as notification: \(title):  \(message)")
        if notificationsEnabled {
            Task(priority: .background) {
                do {
                    clearNotifications()
                    try await sendMessage(title: title, body: message, fromNow: 1) // minimum time seems to be 1 second.
                } catch let error {
                    logger.error("error sending notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func clearNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }
    
    private func sendMessage(title: String, body: String, fromNow: TimeInterval) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: fromNow, repeats: false)
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                                            content: content, trigger: trigger)
        let notificationCenter = UNUserNotificationCenter.current()
        return try await notificationCenter.add(request)
    }
    
    private func enableNotifications() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        let enabled = try await withCheckedThrowingContinuation { continuation in
            center.getNotificationSettings { settings in
                continuation.resume(with: .success(settings.alertSetting == .enabled))
            }
        }
        if enabled {
            return true
        }
        let granted: Bool = try await withCheckedThrowingContinuation { continuation in
            center.requestAuthorization(options: [.alert]) { granted, error in
                if let error = error {
                    continuation.resume(with: .failure(error))
                    return
                } else {
                    continuation.resume(with: .success(granted))
                }
            }
        }
        return granted
    }
}

class PacketTunnelProvider: NEPacketTunnelProvider {
    private let logger: Logger = {
        LoggingSystem.bootstrap(LoggingOSLog.init)
        return Logger(label: "industries.strange.slowdown.tunnel.PacketTunnelProvider")
    }()
    private weak var timeoutTimer: Timer?
    private var observer: AnyObject?
    private let queue = DispatchQueue(label: "industries.strange.slowdown.tunnel.PacketTunnelProvider")
    private var server: Server?
    private var asleep: Bool = false
    
    private var tunConn: TunConn?
    private var device: Device = Device()
    
    override init() {
        FirebaseApp.configure()
        super.init()
        self.tunConn = TunConn {
            return self.packetFlow
        }
        logger.info("init PacketTunnelProvider")
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
            
            self.server = Server.InitTunnelServer(settings: settings, device: device)
            
            self.logger.info("starting server")
            self.server!.startDirectProxyConnection(tunConn: self.tunConn!, settingsData: settingsData)
            self.logger.info("server started")
            
            self.setTunnelNetworkSettings(PacketTunnelProvider.tunnelSettings) { error in
                completionHandler(error)
                self.readOutboundPackets()
            }
        } catch let error {
            Crashlytics.crashlytics().record(error: error)
            fatalError("Encountered error")
        }
    }
    
    private func readOutboundPackets() {
        self.packetFlow.readPacketObjects {[weak self] packets in
            guard let self = self else { return }
            for packet in packets {
                self.server?.writeOutboundPacket(packet.data)
            }
            if self.asleep {
                return
            }
            self.readOutboundPackets()
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
        // Add code here to start the process of stopping the tunnel.
        self.server!.close()
        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        do {
            let response = try server?.rpc(input: messageData)
            completionHandler?(response)
        } catch let error {
            Crashlytics.crashlytics().record(error: error)
            fatalError("Encountered RPC error")
        }
    }
    
    override func sleep(completionHandler: @escaping () -> Void) {
        logger.info("sleeping")
        self.asleep = true
        // Add code here to get ready to sleep.
        completionHandler()
    }
    
    override func wake() {
        logger.info("waking")
        self.asleep = false
        self.readOutboundPackets()
        // Add code here to wake up.
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




