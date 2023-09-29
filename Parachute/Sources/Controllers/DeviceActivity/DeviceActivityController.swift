import Combine
import DeviceActivity
import DI
import FamilyControls
import ManagedSettings
import OSLog
import ProxyService
import SwiftUI

public class DeviceActivityController: ObservableObject {
    public struct Provider: Dep {
        public func create(r _: Registry) -> DeviceActivityController {
            .shared
        }

        public init() {}
    }

    public static let shared = DeviceActivityController()

    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "DeviceActivityController")

    init() {}

    // TODO: unblock all the apps
    public func unblock() {
        for appController in appControlers {
            appController.unblock()
        }
    }

    // TODO: block all the apps
    public func block() {
        for appController in appControlers {
            appController.block()
        }
    }

    private var appControlers: [AppDeviceActivityController] {
        AppController.apps.map(\.dac)
    }

    public var shieldEnabled: Binding<Bool> {
        Binding(
            get: {
                for appController in self.appControlers {
                    if appController.shieldEnabled.wrappedValue {
                        return true
                    }
                }
                return false
            },
            set: {
                if $0 {
                    self.block()
                } else {
                    self.unblock()
                }
            }
        )
    }

    public func syncSettings(settings _: Proxyservice_Settings) {}

    public func initiateMonitoring(timeInterval: TimeInterval) {
        let now = Date()
        let after = now.addingTimeInterval(-1)
        let schedule = DeviceActivitySchedule(
            intervalStart: Calendar.current.dateComponents([.hour, .minute, .second], from: now),
            intervalEnd: Calendar.current.dateComponents([.hour, .minute, .second], from: after),
            repeats: true
//            warningTime: DateComponents(second: 15)
        )

        let center = DeviceActivityCenter()

        // TODO: try combinining applications
        let event = DeviceActivityEvent(
            applications: AppController.instagram.dac.selection.applicationTokens,
            threshold: DateComponents(second: Int(timeInterval))
        )

        let eventName = DeviceActivityEvent.Name("foo")

        do {
            try center.startMonitoring(
                .init("daily"),
                during: schedule,
                events: [
                    eventName: event,
                ]
            )
            logger.info("Monitoring started for the day")
        } catch {
            logger.error("Could not start monitoring \(error)")
        }
    }

    public func stopMonitoring() {
        let center = DeviceActivityCenter()

        center.stopMonitoring([.init("daily")])
        logger.info("Monitoring stopped for the day")
    }
}
