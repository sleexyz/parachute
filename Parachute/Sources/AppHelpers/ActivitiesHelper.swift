import Foundation
import ActivityKit
import Activities
import ProxyService
import OSLog

@available(iOS 16.2, *)
public class ActivitiesHelper {
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

    private func requestActivity(settings: Proxyservice_Settings, isConnected: Bool) {
        do {
            let activity = try Activity.request(attributes: SlowdownWidgetAttributes(), content: self.makeActivityContent(settings, isConnected: isConnected))
            logger.info("requested activity: \(activity.id)")
        } catch (let error) {
            logger.error("error requesting activity: \(error.localizedDescription)")
        }
    }

    func makeActivityContent(_ settings: Proxyservice_Settings, isConnected: Bool) -> ActivityContent<SlowdownWidgetAttributes.ContentState> {
        if settings.hasOverlay && settings.activePreset.id == settings.overlay.preset.id {
            return ActivityContent(state:
                SlowdownWidgetAttributes.ContentState(settings: settings, isConnected: isConnected),
                staleDate: settings.overlay.expiry.date)
        }
        return ActivityContent(state:
            SlowdownWidgetAttributes.ContentState(settings: settings, isConnected: isConnected),
            staleDate: nil)
            
    }

    public func startOrUpdate(settings: Proxyservice_Settings, isConnected: Bool) async -> () {
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

    public func update(settings: Proxyservice_Settings, isConnected: Bool) async -> () {
        if !ActivityAuthorizationInfo().areActivitiesEnabled {
            logger.info("activities not enabled")
            return
        }
        guard let activity = Activity<SlowdownWidgetAttributes>.activities.first else {
            logger.info("no activities found, exiting update")
            return
        }
        await activity.update(
            self.makeActivityContent(settings, isConnected: isConnected),
            alertConfiguration: AlertConfiguration(title: "Delivery update", body: "Your pizza order will arrive in 25 minutes.", sound: .default)
        )
    }
}
