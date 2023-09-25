import Controllers
import DI
import Foundation
import Models
import OSLog
import SwiftUI

public class ActionController: ObservableObject {
    public struct Provider: Dep {
        public func create(r _: Registry) -> ActionController {
            .shared
        }

        public init() {}
    }

    public static let shared = ActionController(
        profileManager: .shared,
        settingsStore: .shared,
        neConfigurationService: .shared,
        connectedViewController: .shared,
        deviceActivityController: .shared,
        activitiesHelper: .shared
    )

    private var profileManager: ProfileManager
    private var settingsStore: SettingsStore
    private var neConfigurationService: NEConfigurationService
    private var connectedViewController: ConnectedViewController
    private var deviceActivityController: DeviceActivityController
    private var activitiesHelper: ActivitiesHelper

    private var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ActionController")

    public init(
        profileManager: ProfileManager,
        settingsStore: SettingsStore,
        neConfigurationService: NEConfigurationService,
        connectedViewController: ConnectedViewController,
        deviceActivityController: DeviceActivityController,
        activitiesHelper: ActivitiesHelper
    ) {
        self.profileManager = profileManager
        self.settingsStore = settingsStore
        self.neConfigurationService = neConfigurationService
        self.connectedViewController = connectedViewController
        self.deviceActivityController = deviceActivityController
        self.activitiesHelper = activitiesHelper
    }

    public func startQuickSession() {
        Task { @MainActor in
            var overlay: Preset = .quickBreak
            let timeInterval = Double(settingsStore.settings.quickSessionSecs)
            overlay.overlayDurationSecs = timeInterval

            try await profileManager.loadPreset(
                preset: .focus,
                overlay: overlay
            )

            deviceActivityController.unblock()
            deviceActivityController.initiateMonitoring(timeInterval: timeInterval)

            ConnectedViewController.shared.set(state: .main)
            if #available(iOS 16.2, *) {
                await ActivitiesHelper.shared.startOrRestart(settings: SettingsStore.shared.settings, isConnected: neConfigurationService.isConnected)
            }
        }
    }

    public func endSession() {
        Task { @MainActor in
            try await profileManager.endSession()
            deviceActivityController.block()
        }
    }

    public func startLongSession() {
        Task { @MainActor in
            do {
                var overlay: Preset = .scrollSession
                let timeInterval = Double(settingsStore.settings.longSessionSecs)
                overlay.overlayDurationSecs = timeInterval

                try await profileManager.loadPreset(
                    preset: .focus,
                    overlay: overlay
                )

                deviceActivityController.unblock()
                deviceActivityController.initiateMonitoring(timeInterval: timeInterval)

                if #available(iOS 16.2, *) {
                    await ActivitiesHelper.shared.startOrRestart(settings: SettingsStore.shared.settings, isConnected: neConfigurationService.isConnected)
                }
                connectedViewController.set(state: .main)
            } catch {
                logger.error("Failed to load preset: \(error)")
            }
        }
    }
}
