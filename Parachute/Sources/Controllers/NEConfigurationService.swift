import ProxyService
import Foundation
import Combine

public typealias NEConfigurationService = FilterConfigurationService

public protocol NEConfigurationServiceProtocol: ObservableObject {
    var isConnected: Bool { get }
    var isLoaded: Bool { get }
    var isInstalled: Bool { get }
    var isTransitioning: Bool { get }
    
    // Loads the network extension configuration.
    func load() async -> ()

    // Starts the network extension.
    func start(settingsOverride: Proxyservice_Settings) async throws

    // Stops the network extension.
    func stop() async throws

    // Installs the network extension.
    func install(settings: Proxyservice_Settings) async throws

    // Sends a message to the network extension.
    func Rpc(request: Proxyservice_Request) async throws -> Data
} 

public extension NEConfigurationServiceProtocol {
    func SetSettings(settings: Proxyservice_Settings) async throws {
        _ = try await self.Rpc(request: Proxyservice_Request.with {
            $0.setSettings = settings
        })
    }
    
    func GetState() async throws -> Proxyservice_GetStateResponse {
        let data = try await self.Rpc(request: Proxyservice_Request.with {
            $0.getState = Proxyservice_GetStateRequest()
        })
        return try Proxyservice_GetStateResponse(serializedData: data)
    }
    
    func Heal() async throws -> Proxyservice_HealResponse{
        let data = try await self.Rpc(request: Proxyservice_Request.with {
            $0.heal = Proxyservice_HealRequest()
        })
        return try Proxyservice_HealResponse(serializedData: data)
    }
}
