//
//  SettingsController.swift
//  slowdown
//
//  Created by Sean Lee on 12/18/22.
//

import Foundation
import SwiftUI
import ProxyService

// Operations for changing settings
class SettingsController: ObservableObject {
    struct Provider: Dep {
        func create(r: Registry) -> SettingsController {
            return SettingsController(
                store: r.resolve(SettingsStore.self),
                service: r.resolve(VPNConfigurationService.self)
            )
        }
    }
    
    private let store: SettingsStore
    private let service: VPNConfigurationService
    
    init(store: SettingsStore, service: VPNConfigurationService) {
        self.store = store
        self.service = service
    }
    
    public func switchMode(mode: Proxyservice_Mode) {
        if mode != store.settings.activePreset.mode {
            store.settings.activePreset.mode = mode
            syncSettings()
        }
    }
    
    @MainActor
    func setSettings(_ op: (_ settings: inout Proxyservice_Settings) -> ()) async throws {
        op(&store.settings)
        if service.isConnected {
            try await service.SetSettings(settings: store.settings)
        }
        try self.store.save()
    }
    
    public func syncSettings() {
        Task.init(priority: .background) {
            try await service.SetSettings(settings: store.settings)
            try self.store.save()
        }
    }
}
