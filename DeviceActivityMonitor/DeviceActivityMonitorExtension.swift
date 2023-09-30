//
//  DeviceActivityMonitorExtension.swift
//  DeviceActivityMonitor
//
//  Created by Sean Lee on 9/14/23.
//

import Common
import Controllers
import DeviceActivity
import ManagedSettings
import OSLog

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "DeviceActivityMonitorExtension")

    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        logger.info("Reached threshold!")
        DeviceActivityController.shared.block()
        // ActionController.shared.startQuietTime()

        do {
            try SettingsStore.shared.load()
            SettingsStore.shared.settings.clearOverlay()
            try SettingsStore.shared.save()
            try SettingsStore.shared.load()
            logger.info("Sucessfully cleared overlay: \(SettingsStore.shared.settings.debugDescription, privacy: .public)")
        } catch {
            logger.error("Failed to save settings: \(error, privacy: .public)")
        }
    }
}
