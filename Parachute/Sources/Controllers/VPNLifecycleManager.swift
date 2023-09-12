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
        public func create(r _: Registry) -> VPNLifecycleManager {
            return .shared
        }

        public init() {}
    }

    public static let shared = VPNLifecycleManager(
        neConfigurationService: NEConfigurationService.shared,
        settingsController: SettingsController.shared,
        settingsStore: SettingsStore.shared,
        queueService: QueueService.shared
    )

    private var neConfigurationService: NEConfigurationService
    private var settingsController: SettingsController
    private var settingsStore: SettingsStore
    private var queueService: QueueService
    private var logger: Logger = .init(subsystem: Bundle.main.bundleIdentifier!, category: "VPNLifecycleManager")
    init(neConfigurationService: NEConfigurationService, settingsController: SettingsController, settingsStore: SettingsStore, queueService: QueueService) {
        self.neConfigurationService = neConfigurationService
        self.settingsController = settingsController
        self.settingsStore = settingsStore
        self.queueService = queueService
    }

    public func pauseConnection(until: Date?) {
        Task {
            try await self.neConfigurationService.stop()
            Analytics.logEvent("pause", parameters: nil)
            if let until = until {
                queueService.registerUnpauseTask(activityId: ActivityHelper.shared.activityId, sendDate: until)
            }
        }
    }

    private func cancelUnpauseTask() {
        queueService.cancelUnpauseTask(activityId: ActivityHelper.shared.activityId)
    }

    public func stopConnection() {
        Task {
            cancelUnpauseTask()
            try await self.neConfigurationService.uninstall()
            if #available(iOS 16.2, *) {
                await ActivitiesHelper.shared.stop()
            }
            Analytics.logEvent("disable", parameters: nil)
        }
    }

    public func startConnection() {
        Task {
            cancelUnpauseTask()
            try await self.neConfigurationService.start(settingsOverride: settingsStore.settings)
            if #available(iOS 16.2, *) {
                await ActivitiesHelper.shared.startOrUpdate(settings: settingsStore.settings, isConnected: true)
            }
            Analytics.logEvent("reenable", parameters: nil)
        }
    }

    public func unpauseConnection() {
        Task {
            cancelUnpauseTask()
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
