//
//  VPNLifecycleManager.swift
//  slowdown
//
//  Created by Sean Lee on 2/15/23.
//

import Foundation
import SwiftProtobuf
import BackgroundTasks
import OSLog
import DI

public class VPNLifecycleManager: ObservableObject {
    public struct Provider: Dep {
        public func create(r: Registry) -> VPNLifecycleManager {
            return VPNLifecycleManager(
                vpnConfigurationService: r.resolve(NEConfigurationService.self),
                settingsController: r.resolve(SettingsController.self),
                settingsStore: r.resolve(SettingsStore.self)
            )
        }
        public init() {}
    }
    private var vpnConfigurationService: NEConfigurationService
    private var settingsController: SettingsController
    private var settingsStore: SettingsStore
    private var logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "VPNLifecycleManager")
    init(vpnConfigurationService: NEConfigurationService, settingsController: SettingsController, settingsStore: SettingsStore) {
        self.vpnConfigurationService = vpnConfigurationService
        self.settingsController = settingsController
        self.settingsStore = settingsStore
    }
    
    public func pauseConnection() {
        Task {
            // try await self.vpnConfigurationService.stopConnectionAndDisableOnDemand()
            try await self.vpnConfigurationService.stop()
            // let request = BGAppRefreshTaskRequest(identifier: NEConfigurationService.unpauseIdentifier)
            // request.earliestBeginDate = Date(timeIntervalSinceNow: 60*60)
            // do {
            //     try BGTaskScheduler.shared.submit(request)
            // } catch {
            //     print("Could not schedule app refresh: \(error)")
            // }
        }
    }
    
    public func startConnection() {
        Task {
            // try await self.vpnConfigurationService.startConnectionAndEnableOnDemand(settingsOverride: settingsStore.settings)
            try await self.vpnConfigurationService.start(settingsOverride: settingsStore.settings)
        }
    }
    
    public func stopConnection() {
        Task {
            // try await self.vpnConfigurationService.stopConnectionAndDisableOnDemand()
            try await self.vpnConfigurationService.stop()
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
