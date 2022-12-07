//
//  VPNConfigurationService.swift
//  slowdown
//
//  Created by Sean Lee on 4/28/22.
//

import NetworkExtension
import Foundation

final class VPNConfigurationService: ObservableObject {
    @Published private(set) var tunnelLoaded = false
    @Published private(set) var tunnel: NETunnelProviderManager?
    @Published private(set) var connected = false
    @Published var isLoading = false
    let store: SettingsStore
    
    static let shared = VPNConfigurationService(store: .shared)
    
    init(store: SettingsStore) {
        self.store = store
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            self.tunnel = managers?.first
            self.tunnelLoaded = true
        }
    // Register to receive notification in your class
        NotificationCenter.default.addObserver(forName: .NEVPNStatusDidChange, object: nil, queue: nil) { notification in
            let conn = notification.object as! NEVPNConnection
            if conn.status == NEVPNStatus.connected {
                self.connected = true
                self.isLoading = false;
                
            }
            if conn.status == NEVPNStatus.connecting{
                self.isLoading = true
                
            }
            if conn.status == NEVPNStatus.disconnected {
                self.connected = false
                self.isLoading = false;
            }
            if conn.status == NEVPNStatus.disconnecting{
                self.isLoading = true
                
            }
        }
    }
    
    // handle notification
    // For swift 4.0 and above put @objc attribute in front of function Definition
    @objc func showSpinningWheel(_ notification: NSNotification) {
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
        proto.serverAddress = "127.0.0.1:8080"
        proto.providerConfiguration = [:]
        
        tunnel.protocolConfiguration = proto

        // Enable the tunnel by default
//        tunnel.isEnabled = true

        return tunnel
    }
}
