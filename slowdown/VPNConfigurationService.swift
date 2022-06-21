//
//  VPNConfigurationService.swift
//  slowdown
//
//  Created by Sean Lee on 4/28/22.
//

import NetworkExtension
import Foundation

final class VPNConfigurationService: ObservableObject {
    @Published private(set) var isStarted = false
    @Published private(set) var tunnel: NETunnelProviderManager?
    
    static let shared = VPNConfigurationService()
    
    init() {
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            self.tunnel = managers?.first
            self.isStarted = true
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
                 self?.tunnel = tunnel
                 completion(.success(()))
             }
         }
     }
    
    private func makeTunnel() -> NETunnelProviderManager {
        let tunnel = NETunnelProviderManager()
        tunnel.localizedDescription = "Slowdown"

        let proto = NETunnelProviderProtocol()
        proto.providerBundleIdentifier = "strangeindustries.slowdown.tunnel"
        proto.serverAddress = "127.0.0.1:4009"
        proto.providerConfiguration = [:]
        
        tunnel.protocolConfiguration = proto

        // Enable the tunnel by default
        tunnel.isEnabled = true

        return tunnel
    }
}
