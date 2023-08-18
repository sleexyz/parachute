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
import Combine
import BackgroundTasks
import Common
import FirebaseCrashlytics
import DI

enum UserError: Error {
    case message(message: String)
}

// TODO: consolidate to this
// and then derive impls for isConnected / isTransitioning from this.
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

public protocol VPNConfigurationServiceProtocol: NEConfigurationServiceProtocol {
    var isTransitioning: Bool { get }
    var conn: NEVPNConnection? { get }
    var status: VPNStatus { get }
    var connectedDate: Date? { get }
    var isLoaded: Bool { get }
    
    func registerBackgroundTasks()
    func setOnDemand(_ value: Bool) async throws
} 

public extension VPNConfigurationServiceProtocol {
    @MainActor
    func stopConnectionAndDisableOnDemand() async throws {
        try await self.stop()
        try await self.setOnDemand(false)
    }

    @MainActor
    func startConnectionAndEnableOnDemand(settingsOverride: Proxyservice_Settings) async throws {
        try await self.start(settingsOverride: settingsOverride)
        try await self.setOnDemand(true)
    }
}

public class VPNConfigurationService: VPNConfigurationServiceProtocol { 
    public static let shared = VPNConfigurationService()
    public struct Provider: Dep {
        public func create(r: Registry) -> NEConfigurationService {
            return .shared
        }
        public init() {}
    }
    
    @Published public var isConnected = false
    @Published public var isTransitioning = false
    @Published public var conn: NEVPNConnection? = nil
    @Published public var status: VPNStatus = .unknown
    @Published public var connectedDate: Date?

    @Published private(set) public var isLoaded = false
    @Published private var manager: NETunnelProviderManager?

    static let unpauseIdentifier = "industries.strange.slowdown.unpause"
    private let logger: Logger = Logger(label: "industries.strange.slowdown.VPNConfigurationService")
    private var bag = Set<AnyCancellable>()
    
    open var isInstalled: Bool {
        return manager != nil
    }
    
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
        if !isLoaded {
            NETunnelProviderManager.loadAllFromPreferences { managers, error in
                self.manager = managers?.first
                self.isLoaded = true
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
    
    public func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: VPNConfigurationService.unpauseIdentifier, using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        let updateTask = Task {
            do {
                // We can't start the connection while the app is backgrounded.
                try await self.setOnDemand(true)
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
    public func setOnDemand(_ value: Bool) async throws {
        self.manager?.isOnDemandEnabled = true
        try await self.saveManagerPreferences()
    }
    
    @MainActor
    public func start(settingsOverride: Proxyservice_Settings?) async throws {
        if let settingsOverride = settingsOverride {
            try self.manager?.connection.startVPNTunnel(options: ["settingsOverride": NSData(data: try settingsOverride.serializedData())])
        } else {
            try self.manager?.connection.startVPNTunnel()
        }
        self.isTransitioning = true
    }
    
    @MainActor
    public func stop() async throws {
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
    
    
    public func install(settings: Proxyservice_Settings) async throws -> () {
        try await Future<(), Error> { promise in
            let tunnel = self.makeNewTunnel()
            tunnel.saveToPreferences { [weak self] error in
                if let error = error {
                    return promise(.failure(error))
                }
                
                // See https://forums.developer.apple.com/thread/25928
                tunnel.loadFromPreferences { [weak self] error in
                    self?.manager = tunnel
                    promise(.success(()))
                }
            }
        }.value
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
    
    public func Rpc(request: Proxyservice_Request) async throws -> Data {
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


public class MockVPNConfigurationService: VPNConfigurationService {
    public struct Provider: MockDep {
        public typealias MockT = MockVPNConfigurationService
        public func create(r: Registry) -> VPNConfigurationService {
            return MockVPNConfigurationService()
        }
        public init() {}
    }
    override public init() {
        super.init()
    }

    public var isInstalledMockOverride: Bool?

    override public var isInstalled: Bool {
        return isInstalledMockOverride ?? super.isInstalled
    }
    public func setIsConnected(value: Bool) {
        self.isConnected = value
    }
}
