import Foundation
import ActivityKit
import Activities
import Logging

public class ActivitiesHelper {
    public static let shared = ActivitiesHelper()

    var logger = Logger(label: "industries.strange.slowdown.ActivitiesHelper")

    @available(iOS 16.2, *)
    public func start() {
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            let initialContentState = SlowdownWidgetAttributes.ContentState(emoji: "😈")
            let activityAttributes = SlowdownWidgetAttributes(name: "Sean")

            let activityContent = ActivityContent(state: initialContentState, staleDate: Calendar.current.date(byAdding: .minute, value: 30, to:Date()))
            
            do {
                let activity = try Activity.request(attributes: activityAttributes, content: activityContent)
                logger.info("requested activity: \(activity)")
            } catch (let error) {
                logger.error("error requesting activity: \(error.localizedDescription)")
            }
        }
    }
}