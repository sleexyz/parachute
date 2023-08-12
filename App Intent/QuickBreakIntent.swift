import AppIntents
import Controllers
import Logging
import AppHelpers

public struct QuickBreakIntent: AppIntent, LiveActivityIntent {
    public static var title: LocalizedStringResource = "Start session"
    public static var description = IntentDescription("Start a 30 second social media session.")
    
    // Not ideal UX wise, but this is necessary for consistent behavior.
    public static var openAppWhenRun: Bool = true

    var logger = Logger(label: "industries.strange.slowdown.QuickBreakIntent")

    public init() {
    }

    public func perform() async throws -> some IntentResult {
        logger.info("QuickBreakIntent.perform")
        guard let profileManager = ProfileManager.shared else  {
            throw MyIntentError.message("ProfileManager not initialized")
        }
        try await profileManager.loadPreset(
            preset: .focus,
            overlay: .quickBreak
        )
        if #available(iOS 16.2, *) {
            await ActivitiesHelper.shared.update(settings: SettingsStore.shared.settings)
        }
        ScrollSessionViewController.shared.setClosed()
        return .result()
    }
}
