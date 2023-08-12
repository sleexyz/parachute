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
import BackgroundTasks
import Common
import FirebaseCrashlytics
import DI

enum UserError: Error {
    case message(message: String)
}

public enum VPNStatus {
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
    public struct Provider: Dep {
        public func create(r: Registry) -> VPNConfigurationService {
            return .shared
        }
        public init() {}
    }
    
    private let logger: Logger = Logger(label: "industries.strange.slowdown.VPNConfigurationService")
    @Published private(set) public var isInitializing = true
    @Published public var isConnected = false
    @Published public var isTransitioning = false
    @Published public var conn: NEVPNConnection? = nil
    @Published private var manager: NETunnelProviderManager?
    @Published public var status: VPNStatus = .unknown
    @Published public var connectedDate: Date?
    
    private var bag = Set<AnyCancellable>()
    
    open var hasManager: Bool {
        return manager != nil
    }
    
    public static let shared = VPNConfigurationService()
    
    
    public init() {
        $status
            .debounce(for: .seconds(10), scheduler: DispatchQueue.main)
            .sink {value in
                if value == .connecting {
                    let msg = "Error connecting, stopping connection attempt"
                    self.logger.error("\(msg)")
                    if Env.value == .prod {
                        Crashlytics.crashlytics().log(msg)
                    }
                    Task {
                        try await self.stopConnectionAndDisableOnDemand()
                    }
                }
            }.store(in: &bag)
    }

    public func load() async -> () {
        self.logger.info("VPNConfigurationService initializing...")
        if isInitializing {
            NETunnelProviderManager.loadAllFromPreferences { managers, error in
                self.manager = managers?.first
                self.isInitializing = false
                self.connectedDate = self.manager?.connection.connectedDate
                self.logger.info("VPNConfigurationService initialized")
            }
        }
        if conn == nil {
            await Future { promise in
                // Register to receive notification in your class
                NotificationCenter.default.addObserver(forName: .NEVPNStatusDidChange, object: nil, queue: nil) { notification in
                    DispatchQueue.main.async {
                        let conn = notification.object as! NEVPNConnection
                        self.connectedDate = self.manager?.connection.connectedDate
                        self.updateStatus(connStatus: conn.status)
                        if conn.status == NEVPNStatus.connected {
                            self.isConnected = true
                            self.isTransitioning = false
                        }
                        if conn.status == NEVPNStatus.connecting{
                            self.isTransitioning = true
                        }
                        if conn.status == NEVPNStatus.disconnecting{
                            self.isTransitioning = true
                        }
                        if conn.status == NEVPNStatus.disconnected {
                            self.isConnected = false
                            self.isTransitioning = false
                        }
                        self.conn = conn
                        promise(.success(()))
                    }
                }
            }.value
        }
    }
    
    static let unpauseIdentifier = "industries.strange.slowdown.unpause"
    public func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: VPNConfigurationService.unpauseIdentifier, using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }
    
    func handleAppRefresh(task: BGAppRefreshTask) {
        let updateTask = Task {
            do {
                // We can't start the connection while the app is backgrounded.
                try await self.enableOnDemand()
                task.setTaskCompleted(success: true)
            } catch {
                task.setTaskCompleted(success: false)
            }
        }
        task.expirationHandler = {
            updateTask.cancel()
        }
    }
    
    @MainActor
    private func updateStatus(connStatus: NEVPNStatus) {
        switch connStatus {
        case .connected:
            status = .connected
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
    public func startConnectionAndEnableOnDemand(settingsOverride: Proxyservice_Settings?) async throws {
        if let settingsOverride = settingsOverride {
            try self.manager?.connection.startVPNTunnel(options: ["settingsOverride": NSData(data: try settingsOverride.serializedData())])
        } else {
            try self.manager?.connection.startVPNTunnel()
        }
        self.isTransitioning = true
        try await enableOnDemand()
    }
    
    @MainActor
    func enableOnDemand() async throws {
        self.manager?.isOnDemandEnabled = true
        try await self.saveManagerPreferences()
    }
    
    @MainActor
    public func stopConnectionAndDisableOnDemand() async throws {
        try await self.stopConnection()
        self.manager?.isOnDemandEnabled = false
        try await self.saveManagerPreferences()
    }
    
    @MainActor
    public func stopConnection() async throws {
        self.manager?.connection.stopVPNTunnel()
        self.isTransitioning = true
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
    
    public func SetSettings(settings: Proxyservice_Settings) async throws {
        _ = try await Rpc(request: Proxyservice_Request.with {
            $0.setSettings = settings
        })
    }
    
    public func GetState() async throws -> Proxyservice_GetStateResponse {
        let data = try await Rpc(request: Proxyservice_Request.with {
            $0.getState = Proxyservice_GetStateRequest()
        })
        return try Proxyservice_GetStateResponse(serializedData: data)
    }
    
    public func Heal() async throws -> Proxyservice_HealResponse{
        let data = try await Rpc(request: Proxyservice_Request.with {
            $0.heal = Proxyservice_HealRequest()
        })
        return try Proxyservice_HealResponse(serializedData: data)
    }
    
    private func Rpc(request: Proxyservice_Request) async throws -> Data {
        guard let session = self.manager?.connection as? NETunnelProviderSession else {
            throw RpcError.serverNotInitializedError
        }
        return try await withCheckedThrowingContinuation { resume in
            do {
                try session.sendProviderMessage(request.serializedData()) { data in
                    guard let data = data else {
                        resume.resume(returning: Data())
                        return
                    }
                    resume.resume(returning: data)
                }
            } catch let error {
                resume.resume(throwing: error)
            }
        }
    }
}

enum RpcError: Error {
    case serverNotInitializedError
    case nilResponseError
    case downstreamError(String)
}

extension RpcError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .nilResponseError: return NSLocalizedString("Server returned nil response", comment: "")
        case .serverNotInitializedError: return NSLocalizedString("Server not initialized", comment: "")
        case .downstreamError(let message): return NSLocalizedString("Downstream error: \(message)", comment: "")
        }
    }
    
}

