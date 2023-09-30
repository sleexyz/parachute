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

    public func startQuietTime() {
        deviceActivityController.block()
        Task { @MainActor in
            try await profileManager.endSession()
        }
    }

    public func startFreeTime(duration: TimeInterval) {
        Task { @MainActor in
            do {
                var overlay: Preset = .scrollSession
                overlay.overlayDurationSecs = duration

                try await profileManager.loadPreset(
                    preset: .focus,
                    overlay: overlay
                )

                // deviceActivityController.syncSettings(settings: settingsStore.settings)
                deviceActivityController.unblock()
                // deviceActivityController.initiateMonitoring(timeInterval: timeInterval)
                deviceActivityController.startMonitoring(duration: duration)

                // TODO: delete
                if #available(iOS 16.2, *) {
                    await ActivitiesHelper.shared.startOrRestart(settings: SettingsStore.shared.settings, isConnected: neConfigurationService.isConnected)
                }
                connectedViewController.set(state: .main)
            } catch {
                logger.error("Failed to load preset: \(error)")
            }
        }
    }

    public func startQuickSession() {
        let duration = Double(settingsStore.settings.quickSessionSecs)
        startFreeTime(duration: duration)
    }

    public func startLongSession() {
        let duration = Double(settingsStore.settings.longSessionSecs)
        startFreeTime(duration: duration)
    }
}
