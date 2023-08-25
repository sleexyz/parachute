import ProxyService
import Foundation
import OSLog
import NetworkExtension
import Combine
import DI
import Common

public class FilterConfigurationService: NEConfigurationServiceProtocol {
    public static let shared = FilterConfigurationService()
    public struct Provider: Dep {
        public func create(r: Registry) -> NEConfigurationService {
            return .shared
        }
        public init() {}
    }
    
    @Published public var isConnected: Bool = false
    @Published public var isLoaded: Bool = false
    @Published public var isTransitioning: Bool = false
    public var isInstalled: Bool {
        NEFilterManager.shared().providerConfiguration != nil
    }
    @Published public var connectedDate: Date? = nil

    private var manager: NEFilterManager = NEFilterManager.shared()
    private let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "FilterConfigurationService")

    @MainActor
    public func load() async -> () {
        self.logger.info("Loading filter configuration service")
        self.isTransitioning = true
        defer {
            self.isTransitioning = false
        }
        guard !isLoaded else {
            return
        }
        do {
            try await loadFilterConfiguration()
            // try await install()
            self.logger.info("Successfully loaded the filter configuration")
            self.isConnected = self.manager.isEnabled
            self.isLoaded = true
        } catch {
            self.logger.info("Error: \(error)")
            self.isLoaded = false
        }
    }

    func loadFilterConfiguration() async throws -> () {
        try await Future<(), Error> { promise in
            NEFilterManager.shared().loadFromPreferences { loadError in
                Task { @MainActor in
                    if let error = loadError {
                        self.logger.error("Failed to load the filter configuration: \(error.localizedDescription)")
                        promise(.failure(error))
                    }
                    promise(.success(()))
                }
            }
        }.value
    }

    @MainActor
    public func install(settings: Proxyservice_Settings) async throws -> () {
        self.isTransitioning = true
        defer {
            self.isTransitioning = false
        }
        try await self.SetSettings(settings: settings)
        self.isConnected = true
        self.logger.info("Successfully saved the filter configuration")
    }

    func saveFilterConfiguration() async throws -> () {
        try await Future<(), Error> { promise in
            NEFilterManager.shared().saveToPreferences { saveError in
                Task { @MainActor in
                    if let error = saveError {
                        self.logger.error("Failed to save the filter configuration: \(error.localizedDescription)")
                        promise(.failure(error))
                    }
                    promise(.success(()))
                }
            }
        }.value
    }

    @MainActor
    public func start(settingsOverride: Proxyservice_Settings) async throws -> () {
        try await install(settings: settingsOverride)
    }

    @MainActor
    public func stop() async throws -> () {
        self.logger.info("Stopping filter configuration service")
        self.isTransitioning = true
        defer {
            self.isTransitioning = false
        }

        guard NEFilterManager.shared().isEnabled else {
            self.logger.info("Filter configuration service is already stopped")
            self.isConnected = false
            return
        }
        try await NEFilterManager.shared().removeFromPreferences()
        self.isConnected = false
        self.logger.info("Successfully removed the filter configuration")
    }
    

    public func Rpc(request: ProxyService.Proxyservice_Request) async throws -> Data {
        let providerConfiguration = NEFilterProviderConfiguration()
        providerConfiguration.filterBrowsers = true
        providerConfiguration.filterSockets = true
        let value = try request.serializedData()
        providerConfiguration.vendorConfiguration = [
            .vendorConfigurationKey: value
        ]

        NEFilterManager.shared().providerConfiguration = providerConfiguration
        NEFilterManager.shared().isEnabled = true
        try await saveFilterConfiguration()
        logger.info("Successfully saved the filter configuration.")

        // TODO: implement when we actually need real data
        return Data()
    }
}
