//
//  DeviceActivityMonitorExtension.swift
//  DeviceActivityMonitor
//
//  Created by Sean Lee on 9/14/23.
//

import DeviceActivity
import ManagedSettings
import Controllers
import OSLog
import Common

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "DeviceActivityMonitorExtension")

    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        DeviceActivityController.shared.block()
    }
}
