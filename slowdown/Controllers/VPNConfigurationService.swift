//
//  VPNConfigurationService.swift
//  slowdown
//
//  Created by Sean Lee on 4/28/22.
//

import NetworkExtension
import Foundation
import ProxyService
import Logging
import SwiftUI

enum UserError: Error {
    case message(message: String)
}


open class VPNConfigurationService: ObservableObject {
    struct Provider: ViewModifier {
        @EnvironmentObject var settings: SettingsStore
        @State var value: VPNConfigurationService?
        
        @ViewBuilder
        func body(content: Content)  -> some View {
            let _ = Self._printChanges()
            Group {
                if value == nil {
                    Rectangle().hidden()
                } else {
                    content.environmentObject(value!)
                }
            }.onAppear {
                value = VPNConfigurationService(store: settings)
            }
        }
    }
    
    private let logger: Logger = Logger(label: "industries.strange.slowdown.VPNConfigurationService")
    @Published private(set) var isInitializing = true
    @Published var isConnected = false
    @Published var isTransitioning = false
    @Published private var manager: NETunnelProviderManager?
    
    var hasManager: Bool {
        return manager != nil
    }
    
    private let store: SettingsStore
    
    init(store: SettingsStore) {
        self.store = store
        logger.info(" init vpnconfigurationservice")
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
    
    
    @MainActor
    func startConnection() async throws {
        try self.manager?.connection.startVPNTunnel()
        self.isTransitioning = true
        self.manager?.isOnDemandEnabled = true
        try await self.saveManagerPreferences()
    }
    
    @MainActor
    public func stopConnection() async throws {
        self.manager?.connection.stopVPNTunnel()
        self.isTransitioning = true
        self.manager?.isOnDemandEnabled = false
        try await self.saveManagerPreferences()
    }
    
    private func saveManagerPreferences() async throws -> () {
        return try await withCheckedThrowingContinuation{ continuation in
            self.manager?.saveToPreferences { error in
                if let error = error {
                    continuation.resume(throwing: error)
                }
                continuation.resume(returning:())
            }
        }
    }
    
    
    public func installVPNProfile(_ completion: @escaping (Result<Void, Error>) -> Void) {
        let tunnel = makeNewTunnel()
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
    
    private func makeNewTunnel() -> NETunnelProviderManager {
        let tunnel = NETunnelProviderManager()
        tunnel.localizedDescription = "Slowdown"
        
        let proto = NETunnelProviderProtocol()
        proto.providerBundleIdentifier = "industries.strange.slowdown.tunnel"
        proto.serverAddress = "127.0.0.1:8080"
        proto.providerConfiguration = [:]
        proto.disconnectOnSleep = true
        
        tunnel.protocolConfiguration = proto
        let rule = NEOnDemandRuleConnect()
        rule.interfaceTypeMatch = .any
        tunnel.onDemandRules = [rule]
        
        // Don't autoconnect on app install -- wait for user to hit start.
        tunnel.isOnDemandEnabled = false
        
        // Enable the tunnel by default
        tunnel.isEnabled = true
        
        return tunnel
    }
    
    func SetSettings(settings: Proxyservice_Settings) async throws {
        var message = Proxyservice_Request()
        message.setSettings = settings
        _ = try await Rpc(message: message)
    }
    
    func GetState() async throws -> Proxyservice_GetStateResponse {
        var message = Proxyservice_Request()
        message.getState = Proxyservice_GetStateRequest()
        return (try await Rpc(message: message)).getState
    }
    
    func Heal() async throws -> Proxyservice_HealResponse{
        var message = Proxyservice_Request()
        message.heal = Proxyservice_HealRequest()
        return (try await Rpc(message: message)).heal
    }
    
    private func Rpc(message: Proxyservice_Request) async throws -> Proxyservice_Response {
        guard let session = self.manager?.connection as? NETunnelProviderSession else {
            throw RpcError.serverNotInitializedError
        }
        return try await withCheckedThrowingContinuation { continuation in
            do {
                self.logger.info("\(message.debugDescription)")
                try session.sendProviderMessage(message.serializedData()) { data in
                    if data == nil {
                        continuation.resume(throwing: RpcError.invalidResponseError)
                        return
                    }
                    do {
                        let resp = try Proxyservice_Response(serializedData: data!)
                        continuation.resume(returning: resp)
                    } catch let error {
                        continuation.resume(with: .failure(error))
                    }
                }
            } catch let error {
                continuation.resume(with: .failure(error))
            }
        }
    }
}

enum RpcError: Error {
    case serverNotInitializedError
    case invalidResponseError
}


class MockVPNConfigurationService: VPNConfigurationService {
    struct Provider: ViewModifier {
        @EnvironmentObject var settings: SettingsStore
        func body(content: Content)  -> some View {
            return content.environmentObject(MockVPNConfigurationService(store: settings))
        }
    }
    var hasManagerOverride: Bool?
    override var hasManager: Bool {
        return hasManagerOverride ?? super.hasManager
    }
    func setIsConnected(value: Bool) {
        self.isConnected = value
    }
}
