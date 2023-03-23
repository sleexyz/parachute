//
//  VPNLifecycleManager.swift
//  slowdown
//
//  Created by Sean Lee on 2/15/23.
//

import Foundation
import SwiftProtobuf
import BackgroundTasks
import Logging

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
    private var logger: Logger = Logger(label: "industries.strange.slowdown.VPNLifecycleManager")
    init(vpnConfigurationService: VPNConfigurationService, settingsController: SettingsController, settingsStore: SettingsStore) {
        self.vpnConfigurationService = vpnConfigurationService
        self.settingsController = settingsController
        self.settingsStore = settingsStore
        self.initialize()
    }
    func initialize() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "industries.strange.slowdown.unpause", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }
    
    func handleAppRefresh(task: BGAppRefreshTask) {
        let updateTask = Task {
            do {
                logger.info("Unpausing")
                // Enable on-demand before starting connection to retry automatically if startConnection fails.
                try await self.vpnConfigurationService.enableOnDemand()
//                try await self.vpnConfigurationService.startConnection()
                logger.info("Unpaused")
                task.setTaskCompleted(success: true)
            } catch {
                task.setTaskCompleted(success: false)
            }
        }
        task.expirationHandler = {
            updateTask.cancel()
        }
    }
    
    public func pauseConnection() {
        Task {
            try await self.vpnConfigurationService.stopConnectionAndDisableOnDemand()
            let request = BGAppRefreshTaskRequest(identifier: "industries.strange.slowdown.unpause")
            request.earliestBeginDate = Date(timeIntervalSinceNow: 5*60) // 15 min for now
            do {
                try BGTaskScheduler.shared.submit(request)
            } catch {
                print("Could not schedule app refresh: \(error)")
            }
        }
    }
    
    public func startConnection() {
        Task {
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
