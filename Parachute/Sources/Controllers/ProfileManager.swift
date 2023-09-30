//
//  PresetManager.swift
//  slowdown
//
//  Created by Sean Lee on 2/18/23.
//

import Combine
import DI
import Foundation
import Models
import OrderedCollections
import OSLog
import ProxyService
import RangeMapping
import SwiftProtobuf
import SwiftUI

var PRESET_OPACITY: Double = 0.8
var OVERLAY_PRESET_OPACITY: Double = PRESET_OPACITY * 0.3

public class ProfileManager: ObservableObject {
    public struct Provider: Dep {
        public func create(r _: Registry) -> ProfileManager {
            .shared
        }

        public init() {}
    }

    public static let shared: ProfileManager = .init(
        settingsStore: SettingsStore.shared,
        settingsController: SettingsController.shared,
        neConfigurationService: NEConfigurationService.shared,
        queueService: QueueService.shared,
        activitiesHelper: ActivitiesHelper.shared
    )

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ProfileManager")
    var settingsStore: SettingsStore
    var settingsController: SettingsController
    var neConfigurationService: NEConfigurationService
    var queueService: QueueService
    var activitiesHelper: ActivitiesHelper

    var bag = Set<AnyCancellable>()

    init(settingsStore: SettingsStore, settingsController: SettingsController, neConfigurationService: NEConfigurationService, queueService: QueueService, activitiesHelper: ActivitiesHelper) {
        self.settingsStore = settingsStore
        self.settingsController = settingsController
        self.neConfigurationService = neConfigurationService
        self.queueService = queueService
        self.activitiesHelper = activitiesHelper
        settingsStore.$settings
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &bag)

        // Necessary to update overlay when activity changes
        // activitiesHelper.$random.receive(on: RunLoop.main).sink { [weak self] _ in
        //     self?.logger.info("PM: activity changed")
        //     self?.fireNormalizeOverlay()
        // }.store(in: &bag)
    }

    @Published public var presetSelectorOpen: Bool = false
    @Published public var profileSelectorOpen: Bool = false

    public var overlayTimer: Timer? = nil
    public var taskId: UIBackgroundTaskIdentifier? = nil

    // NOTE: this does not support long overlays very well.
    @MainActor
    public func loadPreset(preset: Preset, overlay: Preset? = nil) async throws {
        settingsStore.settings.defaultPreset = preset.presetData

        if let overlay {
            guard overlay.overlayDurationSecs != nil else {
                throw UnexpectedError.unexpectedError
            }

            if settingsStore.settings.expiryMechanism == .overlayTimer {
                settingsStore.settings.overlay = Proxyservice_Overlay.with {
                    $0.preset = overlay.presetData
                    $0.expiry = Google_Protobuf_Timestamp(date: Date(timeIntervalSinceNow: Double(overlay.overlayDurationSecs!)))
                }
            } else {
                settingsStore.settings.overlay = Proxyservice_Overlay.with {
                    $0.preset = overlay.presetData
                    $0.usageSecs = overlay.overlayDurationSecs!
                }
            }
        } else {
            settingsStore.settings.clearOverlay()
        }

        try await settingsController.syncSettings()

        if let overlay {
            if settingsStore.settings.expiryMechanism == .overlayTimer {
                syncOverlayTimer()

                if #available(iOS 16.2, *) {
                    queueService.registerActivityRefresh(
                        activityId: settingsStore.settings.userID,
                        refreshDate: Date(timeIntervalSinceNow: Double(overlay.overlayDurationSecs!))
                    )
                }
            }
        }
    }

    public func syncOverlayTimer() {
        guard settingsStore.settings.hasOverlay else {
            return
        }
        let overlay = settingsStore.settings.overlay

        let interval = overlay.expiry.date.timeIntervalSinceNow
        guard interval > 0 else {
            overlayTimer?.invalidate()
            return
        }
        overlayTimer?.invalidate()
        overlayTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
            Task { @MainActor in
                // if let taskId = self.taskId {
                //     UIApplication.shared.endBackgroundTask(taskId)
                // }
                self.settingsController.forceRefresh()
                // if #available(iOS 16.2, *) {
                //     await ActivitiesHelper.shared.startOrUpdate(settings: self.settingsStore.settings, isConnected: self.neConfigurationService.isConnected)
                // }
            }
        }
    }

    func fireNormalizeOverlay() {
        Task {
            try await normalizeOverlay()
        }
    }

    @MainActor
    public func normalizeOverlay() async throws {
        if settingsStore.settings.hasOverlay, settingsStore.settings.overlay.expiry.date.timeIntervalSinceNow < 0 {
            settingsStore.settings.clearOverlay()
            try await settingsController.syncSettings(reason: "Overlay expired")
        }
    }

    @MainActor
    public func endSession() async throws {
        if let taskId {
            UIApplication.shared.endBackgroundTask(taskId)
        }
        if let overlayTimer {
            overlayTimer.invalidate()
        }
        settingsStore.settings.clearOverlay()
        try await settingsController.syncSettings(reason: "Session ended")
        syncOverlayTimer()

        if #available(iOS 16.2, *) {
            await ActivitiesHelper.shared.startOrUpdate(settings: self.settingsStore.settings, isConnected: neConfigurationService.isConnected)
            queueService.cancelActivityRefresh(activityId: settingsStore.settings.userID)
        }
    }

    // Writes through to parachute preset
    public func loadParachutePreset(preset: Preset) {
        Task(priority: .background) {
            try await loadPreset(preset: preset)
            settingsStore.settings.parachutePreset = preset.presetData
            try await settingsController.syncSettings()
        }
    }
}

enum UnexpectedError: Error {
    case unexpectedError
}
