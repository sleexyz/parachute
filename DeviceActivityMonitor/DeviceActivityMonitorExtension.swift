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
        DeviceActivityController.shared.block()
    }
}
