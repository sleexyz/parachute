import ProxyService
import Foundation
import Logging
import NetworkExtension
import Combine
import DI

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
    private let logger: Logger = Logger(label: "industries.strange.slowdown.FilterConfigurationService")


    // Get the Bundle of the system extension.
    lazy var extensionBundle: Bundle = {
        let extensionsDirectoryURL = URL(fileURLWithPath: "Contents/Library/SystemExtensions", relativeTo: Bundle.main.bundleURL)
        let extensionURLs: [URL]
        do {
            extensionURLs = try FileManager.default.contentsOfDirectory(at: extensionsDirectoryURL,
                                                                        includingPropertiesForKeys: nil,
                                                                        options: .skipsHiddenFiles)
        } catch let error {
            fatalError("Failed to get the contents of \(extensionsDirectoryURL.absoluteString): \(error.localizedDescription)")
        }

        guard let extensionURL = extensionURLs.first else {
            fatalError("Failed to find any system extensions")
        }

        guard let extensionBundle = Bundle(url: extensionURL) else {
            fatalError("Failed to create a bundle with URL \(extensionURL.absoluteString)")
        }

        return extensionBundle
    }()

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

    public func install() async throws -> () {
        let providerConfiguration = NEFilterProviderConfiguration()
        providerConfiguration.filterSockets = true
//        providerConfiguration.filterPackets = false
        NEFilterManager.shared().providerConfiguration = providerConfiguration
        NEFilterManager.shared().isEnabled = true
        try await saveFilterConfiguration()
        // registerWithProvider()
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
    public func start(settingsOverride: Proxyservice_Settings?) async throws -> () {
        self.logger.info("Starting filter configuration service")
        self.isTransitioning = true
        defer {
            self.isTransitioning = false
        }
        guard !NEFilterManager.shared().isEnabled else {
            return
        }
        
        try await loadFilterConfiguration()
        NEFilterManager.shared().isEnabled = true
        try await saveFilterConfiguration()
        self.isConnected = true
        self.logger.info("Successfully saved the filter configuration")
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

        guard (try? await loadFilterConfiguration()) != nil else {
            return
        }

        NEFilterManager.shared().isEnabled = false 
        guard (try? await saveFilterConfiguration()) != nil else {
            // Should this revert the isEnabled flag?
            return
        }
        self.isConnected = false
        self.logger.info("Successfully saved the filter configuration")
    }

    // func registerWithProvider() {
    //     IPCConnection.shared.register(withExtension: extensionBundle, delegate: self) { success in
    //         DispatchQueue.main.async {
    //             self.status = (success ? .running : .stopped)
    //         }
    //     }
    // }

    public func Rpc(request: ProxyService.Proxyservice_Request) async throws -> Data {
        throw RpcError.serverNotInitializedError
    }
}
