//
//  VPNLifecycleManager.swift
//  slowdown
//
//  Created by Sean Lee on 2/15/23.
//

import AppHelpers
import BackgroundTasks
import DI
import Firebase
import Foundation
import OSLog
import SwiftProtobuf

public class VPNLifecycleManager: ObservableObject {
    public struct Provider: Dep {
        public func create(r: Registry) -> VPNLifecycleManager {
            return .shared
        }

        public init() {}
    }

    public static let shared = VPNLifecycleManager(
        neConfigurationService: NEConfigurationService.shared,
        settingsController: SettingsController.shared,
        settingsStore: SettingsStore.shared)

    private var neConfigurationService: NEConfigurationService
    private var settingsController: SettingsController
    private var settingsStore: SettingsStore
    private var logger: Logger = .init(subsystem: Bundle.main.bundleIdentifier!, category: "VPNLifecycleManager")
    init(neConfigurationService: NEConfigurationService, settingsController: SettingsController, settingsStore: SettingsStore) {
        self.neConfigurationService = neConfigurationService
        self.settingsController = settingsController
        self.settingsStore = settingsStore
    }
    
    public func pauseConnection() {
        Task {
            // try await self.neConfigurationService.stopConnectionAndDisableOnDemand()
            try await self.neConfigurationService.stop()
             let request = BGAppRefreshTaskRequest(identifier: NEConfigurationService.unpauseIdentifier)
             request.earliestBeginDate = Date(timeIntervalSinceNow: 5*60)
             Analytics.logEvent("pause", parameters: nil)
            
            //  do {
            //      try BGTaskScheduler.shared.submit(request)
            //     if #available(iOS 16.2, *) {
            //         await ActivitiesHelper.shared.startOrUpdate(settings: settingsStore.settings, isConnected: NEConfigurationService.shared.isConnected)
            //     }
            //  } catch {
            //      print("Could not schedule app refresh: \(error)")
            //  }
        }
    }

    public func stopConnection() {
        Task {
            self.neConfigurationService.cancelPause()
            try await self.neConfigurationService.uninstall()
            if #available(iOS 16.2, *) {
                await ActivitiesHelper.shared.stop()
            }
            Analytics.logEvent("disable", parameters: nil)
        }
    }

    public func startConnection() {
        Task {
            self.neConfigurationService.cancelPause()
            try await self.neConfigurationService.start(settingsOverride: settingsStore.settings)
            if #available(iOS 16.2, *) {
                await ActivitiesHelper.shared.startOrUpdate(settings: settingsStore.settings, isConnected: true)
            }
            Analytics.logEvent("reenable", parameters: nil)
        }
    }

    public func unpauseConnection() {
        Task {
            self.neConfigurationService.cancelPause()
            try await self.neConfigurationService.start(settingsOverride: settingsStore.settings)
            if #available(iOS 16.2, *) {
                await ActivitiesHelper.shared.startOrUpdate(settings: settingsStore.settings, isConnected: true)
            }
            // try await self.neConfigurationService.startConnectionAndEnableOnDemand(settingsOverride: settingsStore.settings)
            try await self.neConfigurationService.start(settingsOverride: settingsStore.settings)
            Analytics.logEvent("unpause", parameters: nil)
        }
    }
}
