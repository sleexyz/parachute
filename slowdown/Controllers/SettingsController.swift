//
//  SettingsController.swift
//  slowdown
//
//  Created by Sean Lee on 12/18/22.
//

import Foundation
import ProxyService

struct SettingsController {
    private let store: SettingsStore
    private let service: VPNConfigurationService
    
    static let shared = SettingsController(store: .shared, service: .shared)
    
    init(store: SettingsStore, service: VPNConfigurationService) {
        self.store = store
        self.service = service
    }
    
    public func switchMode(mode: Proxyservice_Mode) {
        if mode != store.settings.mode {
            store.settings.mode = mode
            syncSettings()
        }
    }
    
    public func syncSettings() {
        Task.init(priority: .background) {
            try await service.SetSettings(settings: store.settings)
            try self.store.save()
        }
    }
}
