//
//  VPNConfigurationService.swift
//  slowdown
//
//  Created by Sean Lee on 4/28/22.
//

import NetworkExtension
import Foundation
import os
import ProxyService

enum UserError: Error {
    case message(message: String)
}

final class VPNConfigurationService: ObservableObject {
    @Published private(set) var isInitializing = true
    @Published private(set) var isConnected = false
    @Published var isTransitioning = false
    @Published private var manager: NETunnelProviderManager?
    
    var hasManager: Bool {
        return manager != nil
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
            DispatchQueue.main.async {
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
        }
    }
    
    func startCheat() async throws -> () {
        try await self.SetTemporaryRxSpeedTarget(speed: -1, duration: 60)
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

extension VPNConfigurationService {
    func SetTemporaryRxSpeedTarget(speed: Float64, duration: Int32) async throws {
        var message = Proxyservice_Request()
        message.setTemporaryRxSpeedTarget.duration = 60
        message.setTemporaryRxSpeedTarget.speed = -1
        os_log("\(message.debugDescription)")
        return try await Rpc(message: message)
    }
    func Rpc(message: Proxyservice_Request) async throws {
        guard let session = self.manager?.connection as? NETunnelProviderSession else {
            return
        }
        return try await withCheckedThrowingContinuation { continuation in
            do {
                try session.sendProviderMessage(message.serializedData()) { response in
                    if response != nil {
                        let responseString = NSString(data: response!, encoding: String.Encoding.utf8.rawValue)
                        os_log("Received response frommm the provider: \(responseString)")
                        continuation.resume(returning: ())
                    } else {
                        os_log("Got a nil response from the provider")
                        continuation.resume(throwing: UserError.message(message: "Got a nil response from the provider"))
                    }
                }
            } catch let error {
                continuation.resume(with: .failure(error))
            }
        }
    }
}
