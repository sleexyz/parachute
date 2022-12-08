//
//  VPNConfigurationService.swift
//  slowdown
//
//  Created by Sean Lee on 4/28/22.
//

import NetworkExtension
import Foundation
import os
import UserNotifications

final class VPNConfigurationService: ObservableObject {
    @Published private(set) var isInitializing = true
    @Published private(set) var isConnected = false
    @Published var isTransitioning = false
    @Published private var manager: NETunnelProviderManager?
    
    @Published private var cheatDeadline: Date?
    
    var hasManager: Bool {
        return manager != nil
    }
    
    var isCheating: Bool {
        return cheatDeadline != nil && cheatDeadline! > Date()
    }
    var cheatTimeLeft: Int {
        if cheatDeadline == nil {
            return 0
        }
        return Int(cheatDeadline!.timeIntervalSinceNow)
    }
    
    let store: SettingsStore
    
    static let shared = VPNConfigurationService(store: .shared)
    
    init(store: SettingsStore) {
        self.store = store
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            self.manager = managers?.first
            self.isInitializing = false
        }
        
        // Register to receive notification in your class
        NotificationCenter.default.addObserver(forName: .NEVPNStatusDidChange, object: nil, queue: nil) { notification in
            let conn = notification.object as! NEVPNConnection
            if conn.status == NEVPNStatus.connected {
                self.isConnected = true
                self.isTransitioning = false;
                
            }
            if conn.status == NEVPNStatus.connecting{
                self.isTransitioning = true
            }
            if conn.status == NEVPNStatus.disconnected {
                self.isConnected = false
                self.isTransitioning = false;
            }
            if conn.status == NEVPNStatus.disconnecting{
                self.isTransitioning = true
            }
        }
        
        // Register to receive notification in your class
        NotificationCenter.default.addObserver(forName: .NEVPNConfigurationChange, object: nil, queue: nil) { notification in
            os_log("notification: \(notification.description)")
            //            let conn = notification.object as! NEVPNConnection
            //            if conn.status == NEVPNStatus.connected {
            //                self.connected = true
            //                self.isLoading = false;
            //
            //            }
            //            if conn.status == NEVPNStatus.connecting{
            //                self.isLoading = true
            //            }
            //            if conn.status == NEVPNStatus.disconnected {
            //                self.connected = false
            //                self.isLoading = false;
            //            }
            //            if conn.status == NEVPNStatus.disconnecting{
            //                self.isLoading = true
            //            }
        }
    }
    
    func enableNotifications() async throws -> Bool {
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
    
    func startCheat() async throws {
        let _ = try await enableNotifications()
        
        guard let session = self.manager?.connection as? NETunnelProviderSession else {
            return
        }
        
        let message = "cheat".data(using: String.Encoding.utf8)
        try session.sendProviderMessage(message!) { response in
            if response != nil {
                let responseString = NSString(data: response!, encoding: String.Encoding.utf8.rawValue)
                os_log("Received response from the provider: \(responseString)")
            } else {
                os_log("Got a nil response from the provider")
            }
        }
        DispatchQueue.main.async {
            self.cheatDeadline = Date().addingTimeInterval(60)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(60)) {
                    os_log("invalidating cheat time")
            self.cheatDeadline = nil
        }
        try await self.sendMessage(title: "Cheat ended", body: "", fromNow: 60)
    }
    
    func sendMessage(title: String, body: String, fromNow: TimeInterval) async throws {
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
    
    
    func startConnection(debug: Bool) throws {
        //        if !self.manager?.isEnabled {
        //
        //        }
        try self.manager?.connection.startVPNTunnel(options: [
            "debug": NSNumber(booleanLiteral: debug)
        ])
        self.isTransitioning = true
    }
    
    func stopConnection() {
        self.manager?.connection.stopVPNTunnel()
        self.isTransitioning = true
    }
    
    private func saveToPreferences() {
        //        isLoading = true
        self.manager!.saveToPreferences { [weak self] error in
            //            guard let self = self else { return }
            //            self.isLoading = false
            
            //            if let error = error {
            //                self.showError(title: "Failed to update VPN configuration", message: error.localizedDescription)
            //                self.errorMessage = error.localizedDescription
            //                return
            //            }
        }
    }
    
    func installProfile(_ completion: @escaping (Result<Void, Error>) -> Void) {
        let tunnel = makeTunnel()
        tunnel.saveToPreferences { [weak self] error in
            if let error = error {
                return completion(.failure(error))
            }
            
            // See https://forums.developer.apple.com/thread/25928
            tunnel.loadFromPreferences { [weak self] error in
                self?.manager = tunnel
                completion(.success(()))
            }
        }
    }
    
    private func makeTunnel() -> NETunnelProviderManager {
        let tunnel = NETunnelProviderManager()
        tunnel.localizedDescription = "Slowdown"
        
        let proto = NETunnelProviderProtocol()
        proto.providerBundleIdentifier = "strangeindustries.slowdown.tunnel"
        proto.serverAddress = "127.0.0.1:8080"
        proto.providerConfiguration = [:]
        
        tunnel.protocolConfiguration = proto
        
        // Enable the tunnel by default
        tunnel.isEnabled = true
        
        return tunnel
    }
}
