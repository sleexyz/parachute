import Foundation
import ActivityKit
import Activities
import Logging
import ProxyService

public class ActivitiesHelper {
    public static let shared = ActivitiesHelper()

    var logger = Logger(label: "industries.strange.slowdown.ActivitiesHelper")

    @available(iOS 16.2, *)
    public func start(settings: Proxyservice_Settings) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            logger.info("activities not enabled")
            return
        }
        if Activity<SlowdownWidgetAttributes>.activities.first == nil {
            requestActivity(settings: settings)
        }
    }

    @available(iOS 16.2, *)
    private func requestActivity(settings: Proxyservice_Settings) {
        do {
            let activity = try Activity.request(attributes: SlowdownWidgetAttributes(), content: self.makeActivityContent(settings))
            logger.info("requested activity: \(activity)")
        } catch (let error) {
            logger.error("error requesting activity: \(error.localizedDescription)")
        }
    }

    @available(iOS 16.2, *)
    func makeActivityContent(_ settings: Proxyservice_Settings) -> ActivityContent<SlowdownWidgetAttributes.ContentState> {
        if settings.hasOverlay && settings.activePreset.id == settings.overlay.preset.id {
            return ActivityContent(state:
                SlowdownWidgetAttributes.ContentState(settings: settings),
                staleDate: settings.overlay.expiry.date)
        }
        return ActivityContent(state:
            SlowdownWidgetAttributes.ContentState(settings: settings),
            staleDate: nil)
            
    }

    @available(iOS 16.2, *)
    public func startOrUpdate(settings: Proxyservice_Settings) async -> () {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            logger.info("activities not enabled")
            return
        }
        guard Activity<SlowdownWidgetAttributes>.activities.first != nil else {
            start(settings: settings)
            return
        }
        await update(settings: settings)
    }

    @available(iOS 16.2, *)
    public func update(settings: Proxyservice_Settings) async -> () {
        if !ActivityAuthorizationInfo().areActivitiesEnabled {
            logger.info("activities not enabled")
            return
        }
        guard let activity = Activity<SlowdownWidgetAttributes>.activities.first else {
            logger.info("no activities found, exiting update")
            return
        }
        await activity.update(
            self.makeActivityContent(settings), 
            alertConfiguration: AlertConfiguration(title: "Delivery update", body: "Your pizza order will arrive in 25 minutes.", sound: .default)
        )
    }
}
