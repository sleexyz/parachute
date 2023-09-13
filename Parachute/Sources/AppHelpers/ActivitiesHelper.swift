import Activities
import ActivityKit
import Foundation
import OSLog
import ProxyService
import OneSignalFramework
import SwiftUI

@available(iOS 16.2, *)
public class ActivitiesHelper {
    @AppStorage("userId") private var userId = UUID().uuidString

    // TODO: generate one of these for each activity
    public var activityId: String {
        userId
    } 

    public var activity: Activity<SlowdownWidgetAttributes>? = nil

    public static let shared = ActivitiesHelper()

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
        if let activity = activity {
            if activity.activityState != .dismissed {
                return activity
            }
        }
        self.activity = Activity<SlowdownWidgetAttributes>.activities.first(where: { activity in
            activity.activityState != .dismissed
        })
        return self.activity
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
            
            Task {
                for await data in activity.pushTokenUpdates {
                    let myToken = data.map {String(format: "%02x", $0)}.joined()
                    OneSignal.LiveActivities.enter(activityId, withToken: myToken)
                    logger.info("push token: \(myToken)")
                }
            }
            logger.info("requested activity: \(activity.id)")
        } catch {
            logger.error("error requesting activity: \(error.localizedDescription)")
        }
    }

    func makeActivityContent(_ settings: Proxyservice_Settings, isConnected: Bool) -> ActivityContent<SlowdownWidgetAttributes.ContentState> {
        if settings.hasOverlay, settings.activePreset.id == settings.overlay.preset.id {
            return ActivityContent(state:
                SlowdownWidgetAttributes.ContentState(settings: settings, isConnected: isConnected),
                staleDate: settings.overlay.expiry.date)
        }
        return ActivityContent(state:
            SlowdownWidgetAttributes.ContentState(settings: settings, isConnected: isConnected),
            staleDate: nil)
    }
    
    public func startOrRestart(settings: Proxyservice_Settings, isConnected: Bool) async {
        guard ensureEnabled() else {
            return
        }
        if ensureActive() != nil {
            stop()
        }
        start(settings: settings, isConnected: isConnected)
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
