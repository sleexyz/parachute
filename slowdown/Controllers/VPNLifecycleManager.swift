//
//  VPNLifecycleManager.swift
//  slowdown
//
//  Created by Sean Lee on 2/15/23.
//

import Foundation
import SwiftProtobuf

class VPNLifecycleManager: ObservableObject {
    struct Provider: Dep {
        func create(r: Registry) -> VPNLifecycleManager {
            return VPNLifecycleManager(
                vpnConfigurationService: r.resolve(VPNConfigurationService.self),
                settingsController: r.resolve(SettingsController.self),
                settingsStore: r.resolve(SettingsStore.self)
            )
        }
    }
    private var vpnConfigurationService: VPNConfigurationService
    private var settingsController: SettingsController
    private var settingsStore: SettingsStore
    
    init(vpnConfigurationService: VPNConfigurationService, settingsController: SettingsController, settingsStore: SettingsStore) {
        self.vpnConfigurationService = vpnConfigurationService
        self.settingsController = settingsController
        self.settingsStore = settingsStore
    }
    
    public func pauseConnection() {
        Task {
            try await vpnConfigurationService.stopConnection()
            try await settingsController.setSettings { settings in
                settings.pauseExpiry = Google_Protobuf_Timestamp(date: Date(timeIntervalSinceNow: 1 * 60 * 60))
            }
        }
    }
    
    public func startConnection() {
        Task {
            if settingsStore.settings.isPaused() {
                try await settingsController.setSettings { settings in
                    settings.clearPauseExpiry()
                }
            }
            try await self.vpnConfigurationService.startConnectionAndEnableOnDemand()
        }
    }
    
    public func stopConnection() {
        Task {
            try await self.vpnConfigurationService.stopConnectionAndDisableOnDemand()
        }
    }
    
    public func toggleConnection() {
        if vpnConfigurationService.isConnected {
            stopConnection()
        } else {
            startConnection()
        }
    }
}
