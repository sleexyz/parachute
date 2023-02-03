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
import Combine
import Common
import FirebaseCrashlytics

enum UserError: Error {
    case message(message: String)
}

enum VPNStatus {
    case unknown
    case connected
    case connecting
    case disconnected
    case disconnecting
    
    var isConnected: Bool {
        switch self {
        case .connected, .disconnecting: return true
        default: return false
        }
    }
    
    var isTransitioning: Bool {
        switch self {
        case .connecting, .disconnecting: return true
        default: return false
        }
    }
}

extension Future where Failure == Never {
    convenience init(operation: @escaping () async -> Output) {
        self.init { promise in
            Task {
                let output = await operation()
                promise(.success(output))
            }
        }
    }
}

open class VPNConfigurationService: ObservableObject {
    struct Provider: Dep {
        func create(r: Registry) -> VPNConfigurationService {
            return VPNConfigurationService(store: r.resolve(SettingsStore.self))
        }
    }
    
    private let logger: Logger = Logger(label: "industries.strange.slowdown.VPNConfigurationService")
    @Published private(set) var isInitializing = true
    @Published var isConnected = false
    @Published var isTransitioning = false
    @Published private var manager: NETunnelProviderManager?
    @Published var status: VPNStatus = .unknown
    
    private var bag = Set<AnyCancellable>()
    
    var hasManager: Bool {
        return manager != nil
    }
    
    private let store: SettingsStore
    
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
                self.updateStatus(connStatus: conn.status)
                if conn.status == NEVPNStatus.connected {
                    self.isConnected = true
                    self.isTransitioning = false;
                }
                if conn.status == NEVPNStatus.connecting{
                    self.isTransitioning = true
                }
                if conn.status == NEVPNStatus.disconnecting{
                    self.isTransitioning = true
                }
                if conn.status == NEVPNStatus.disconnected {
                    self.isConnected = false
                    self.isTransitioning = false;
                }
            }
        }
        
        
        bag.update(with: $status
            .debounce(for: .seconds(10), scheduler: DispatchQueue.main)
            .sink {  value in
                if value == .connecting {
                    let msg = "Error connecting, stopping connection attempt"
                    self.logger.error("\(msg)")
                    if Env.value == .prod {
                        Crashlytics.crashlytics().log(msg)
                    }
                    Task {
                        try await self.stopConnection()
                    }
                }
            })
    }
    
    @MainActor
    private func updateStatus(connStatus: NEVPNStatus) {
        switch connStatus {
        case .connected: status = .connected
        case .connecting: status = .connecting
        case .disconnecting: status = .disconnecting
        case .disconnected: status = .disconnected
        case .invalid:
            fatalError("unexpected")
        case .reasserting:
            fatalError("unexpected")
        @unknown default:
            status = .unknown
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
        return try await Future<Proxyservice_Response, Error>() { promise in
            do {
                try session.sendProviderMessage(message.serializedData()) { data in
                    if data == nil {
                        promise(.failure(RpcError.invalidResponseError))
                        return
                    }
                    do {
                        let resp = try Proxyservice_Response(serializedData: data!)
                        promise(.success(resp))
                    } catch let error {
                        promise(.failure(error))
                    }
                }
            } catch let error {
                promise(.failure(error))
            }
        }.value
    }
}

enum RpcError: Error {
    case serverNotInitializedError
    case invalidResponseError
}

extension RpcError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidResponseError: return NSLocalizedString("Server returned invalid response", comment: "")
        case .serverNotInitializedError: return NSLocalizedString("Server not initialized", comment: "")
        }
    }
    
}

