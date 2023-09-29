import Activities
import ActivityKit
import DI
import Foundation
import OneSignalFramework
import OSLog
import ProxyService
import SwiftUI

public class ActivitiesHelper: ObservableObject {
    public struct Provider: Dep {
        public func create(r _: Registry) -> ActivitiesHelper {
            .shared
        }

        public init() {}
    }

    public static let shared = ActivitiesHelper()

    public var activity: Activity<SlowdownWidgetAttributes>? = nil
    @Published public var random: String = UUID().uuidString

    var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ActivitiesHelper")

    public func start(settings: Proxyservice_Settings, isConnected: Bool) {
        guard ensureEnabled() else {
            return
        }
        if ensureActive() == nil {
            requestActivity(settings: settings, isConnected: isConnected)
        } else {
            logger.info("activity already active, exiting start")
        }
    }

    private func ensureEnabled() -> Bool {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            logger.info("activities not enabled")
            return false
        }
        guard ActivityAuthorizationInfo().frequentPushesEnabled else {
            logger.info("frequent pushes are not enabled")
            return false
        }
        return true
    }

    private func ensureActive() -> Activity<SlowdownWidgetAttributes>? {
        if let activity {
            if activity.activityState != .dismissed {
                return activity
            }
        }
        activity = Activity<SlowdownWidgetAttributes>.activities.first(where: { activity in
            activity.activityState != .dismissed
        })
        if let activity {
            subscribeToActivityChanges(activity: activity)
            return activity
        }
        return activity
    }

    public func stop() {
        guard ensureEnabled() else {
            return
        }
        if let activity = ensureActive() {
            Task {
                await activity.end(ActivityContent(state: activity.content.state, staleDate: nil), dismissalPolicy: .immediate)
                self.activity = nil
            }
        } else {
            logger.info("no active activity, nothing to stop")
        }
    }

    private func requestActivity(settings: Proxyservice_Settings, isConnected: Bool) {
        do {
            let activity = try Activity.request(
                attributes: SlowdownWidgetAttributes(),
                content: makeActivityContent(settings, isConnected: isConnected),
                pushType: .token
            )
            self.activity = activity

            // if let data = activity.pushToken {
            //     let myToken = data.map {String(format: "%02x", $0)}.joined()
            //     OneSignal.LiveActivities.enter(activityId, withToken: myToken)
            //     logger.info("push token: \(myToken)")
            // }

            subscribeToActivityChanges(activity: activity)

            logger.info("requested activity: \(activity.id)")
        } catch {
            logger.error("error requesting activity: \(error.localizedDescription)")
        }
    }

    func subscribeToActivityChanges(activity: Activity<SlowdownWidgetAttributes>) {
        Task { @MainActor in
            for await data in activity.pushTokenUpdates {
                let myToken = data.map { String(format: "%02x", $0) }.joined()
                OneSignal.LiveActivities.enter(SettingsStore.shared.settings.userID, withToken: myToken)
                logger.info("push token: \(myToken)")
            }
        }

        Task { @MainActor in
            for await _ in activity.contentUpdates {
                logger.info("activity update")
                self.random = UUID().uuidString
                // self.objectWillChange.send()
            }
        }
    }

    func makeActivityContent(_ settings: Proxyservice_Settings, isConnected: Bool) -> ActivityContent<SlowdownWidgetAttributes.ContentState> {
        if settings.isInScrollSession {
            return ActivityContent(state:
                SlowdownWidgetAttributes.ContentState(settings: settings, isConnected: isConnected),
                staleDate: settings.overlay.expiry.date)
        }

        return ActivityContent(state:
            SlowdownWidgetAttributes.ContentState(settings: settings, isConnected: isConnected),
            staleDate: nil)
    }

    public func startOrRestart(settings: Proxyservice_Settings, isConnected: Bool) async {
        await startOrUpdate(settings: settings, isConnected: isConnected)
        // guard ensureEnabled() else {
        //     return
        // }
        // if ensureActive() != nil {
        //     stop()
        // }
        // start(settings: settings, isConnected: isConnected)
    }

    public func startOrUpdate(settings: Proxyservice_Settings, isConnected: Bool) async {
        guard ensureEnabled() else {
            return
        }
        guard ensureActive() != nil else {
            start(settings: settings, isConnected: isConnected)
            return
        }
        await update(settings: settings, isConnected: isConnected)
    }

    private func update(settings: Proxyservice_Settings, isConnected: Bool) async {
        guard ensureEnabled() else {
            return
        }
        guard ensureActive() != nil else {
            logger.info("no activities found, exiting update")
            return
        }
        await activity?.update(
            makeActivityContent(settings, isConnected: isConnected),
            alertConfiguration: AlertConfiguration(title: "Delivery update", body: "Your pizza order will arrive in 25 minutes.", sound: .default)
        )
    }
}
