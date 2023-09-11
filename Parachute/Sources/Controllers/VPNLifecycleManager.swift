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
            VPNLifecycleManager(
                neConfigurationService: r.resolve(NEConfigurationService.self),
                settingsController: r.resolve(SettingsController.self),
                settingsStore: r.resolve(SettingsStore.self)
            )
        }

        public init() {}
    }

    private var neConfigurationService: NEConfigurationService
    private var settingsController: SettingsController
    private var settingsStore: SettingsStore
    private var logger: Logger = .init(subsystem: Bundle.main.bundleIdentifier!, category: "VPNLifecycleManager")
    init(neConfigurationService: NEConfigurationService, settingsController: SettingsController, settingsStore: SettingsStore) {
        self.neConfigurationService = neConfigurationService
        self.settingsController = settingsController
        self.settingsStore = settingsStore
    }

    // TODO: add analytics here to determine timing
    public func pauseConnection() {
        Task {
            // try await self.neConfigurationService.stopConnectionAndDisableOnDemand()
            try await self.neConfigurationService.stop()
            let request = BGAppRefreshTaskRequest(identifier: NEConfigurationService.unpauseIdentifier)
            request.earliestBeginDate = Date(timeIntervalSinceNow: 5 * 60)
            Analytics.logEvent("pause", parameters: nil)

            do {
                try BGTaskScheduler.shared.submit(request)
                if #available(iOS 16.2, *) {
                    await ActivitiesHelper.shared.startOrUpdate(settings: settingsStore.settings, isConnected: NEConfigurationService.shared.isConnected)
                }
            } catch {
                print("Could not schedule app refresh: \(error)")
            }
        }
    }

    public func startConnection() {
        Task {
            Analytics.logEvent("reenable", parameters: nil)
            self.neConfigurationService.cancelPause()
            try await self.neConfigurationService.start(settingsOverride: settingsStore.settings)
            if #available(iOS 16.2, *) {
                await ActivitiesHelper.shared.startOrUpdate(settings: settingsStore.settings, isConnected: true)
            }
        }
    }
}
