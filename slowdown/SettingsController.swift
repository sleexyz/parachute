//
//  SettingsController.swift
//  slowdown
//
//  Created by Sean Lee on 12/18/22.
//

import Foundation


struct SettingsController {
    private let store: SettingsStore
    private let service: VPNConfigurationService
    
    static let shared = SettingsController(store: .shared, service: .shared)
    
    init(store: SettingsStore, service: VPNConfigurationService) {
        self.store = store
        self.service = service
    }
    
    public func syncSettings() {
        Task.init(priority: .background) {
            try await service.SetSettings(settings: store.settings)
            try self.store.save()
        }
    }
}
