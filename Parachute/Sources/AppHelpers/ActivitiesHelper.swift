import Activities
import ActivityKit
import Foundation
import OSLog
import ProxyService
import OneSignalFramework

@available(iOS 16.2, *)
public class ActivitiesHelper {
    @AppStorage("userId") private var userId = UUID().uuidString

    // TODO: generate one of these for each activity
    var activityId: String {
        userId
    } 

    public static let shared = ActivitiesHelper()

    var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ActivitiesHelper")

    public func start(settings: Proxyservice_Settings, isConnected: Bool) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            logger.info("activities not enabled")
            return
        }
        if Activity<SlowdownWidgetAttributes>.activities.first == nil {
            requestActivity(settings: settings, isConnected: isConnected)
        }
    }

    public func stop() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            logger.info("activities not enabled")
            return
        }
        if let activity = Activity<SlowdownWidgetAttributes>.activities.first {
            Task {
                await activity.end(ActivityContent(state: activity.content.state, staleDate: nil), dismissalPolicy: .immediate)
            }
        }
    }

    private func requestActivity(settings: Proxyservice_Settings, isConnected: Bool) {
        do {
            let activity = try Activity.request(
                attributes: SlowdownWidgetAttributes(), 
                content: makeActivityContent(settings, isConnected: isConnected),
                pushType: .token
            )
            
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

    public func startOrUpdate(settings: Proxyservice_Settings, isConnected: Bool) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            logger.info("activities not enabled")
            return
        }
        guard Activity<SlowdownWidgetAttributes>.activities.first != nil else {
            start(settings: settings, isConnected: isConnected)
            return
        }
        await update(settings: settings, isConnected: isConnected)
    }

    private func update(settings: Proxyservice_Settings, isConnected: Bool) async {
        if !ActivityAuthorizationInfo().areActivitiesEnabled {
            logger.info("activities not enabled")
            return
        }
        guard let activity = Activity<SlowdownWidgetAttributes>.activities.first else {
            logger.info("no activities found, exiting update")
            return
        }
        await activity.update(
            makeActivityContent(settings, isConnected: isConnected),
            alertConfiguration: AlertConfiguration(title: "Delivery update", body: "Your pizza order will arrive in 25 minutes.", sound: .default)
        )
    }
}
