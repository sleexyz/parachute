import ProxyService
import AppHelpers
import Foundation
import OSLog
import NetworkExtension
import Combine
import DI
import Common
import BackgroundTasks
import Firebase

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

    public func loadFilterConfiguration() async throws -> () {
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
        self.logger.info("Successfully updated an installed filter configuration")
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

        NEFilterManager.shared().isEnabled = false
        try await saveFilterConfiguration()
        self.isConnected = false
        self.logger.info("Successfully updated the stopped filter configuration")
    }

    @MainActor
    public func uninstall() async throws -> () {
        self.logger.info("Uninstalling filter configuration service")
        self.isTransitioning = true
        defer {
            self.isTransitioning = false
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

    static let unpauseIdentifier = "industries.strange.slowdown.unpause"

    public func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: VPNConfigurationService.unpauseIdentifier, using: nil) { task in
            self.handleUnpause(bgAppRefreshTask: task as! BGAppRefreshTask)
        }
    }

    public func cancelPause() {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: VPNConfigurationService.unpauseIdentifier) 
    }

    private func handleUnpause(bgAppRefreshTask: BGAppRefreshTask) {
        let unpauseTask = Task {
            do {
                try await self.start(settingsOverride: SettingsStore.shared.settings)
                Analytics.logEvent("unpause", parameters: nil)
                bgAppRefreshTask.setTaskCompleted(success: true)
                if #available(iOS 16.2, *) {
                    await ActivitiesHelper.shared.update(settings: SettingsStore.shared.settings, isConnected: isConnected)
                }
                // TODO: make sure UI is in sync on load
            } catch {
                bgAppRefreshTask.setTaskCompleted(success: false)
            }
        }
        bgAppRefreshTask.expirationHandler = {
            unpauseTask.cancel()
        }
    }
    
}
