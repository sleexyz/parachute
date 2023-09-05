import AppHelpers
import AppIntents
import Controllers
import Models
import OSLog

public struct QuickBreakIntent: AppIntent, LiveActivityIntent {
    public static var title: LocalizedStringResource = "Start session"
    public static var description = IntentDescription("Start a 30 second social media session.")

    // Not ideal UX wise, but this is necessary for consistent behavior.
    public static var openAppWhenRun: Bool = true

    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "QuickBreakIntent")

    public init() {}

    public func perform() async throws -> some IntentResult {
        logger.info("QuickBreakIntent.perform")
        guard let profileManager = ProfileManager.shared else {
            throw MyIntentError.message("ProfileManager not initialized")
        }

        var overlay: Preset = .quickBreak
        overlay.overlayDurationSecs = Double(SettingsStore.shared.settings.quickSessionSecs)

        try await ProfileManager.shared.loadPreset(
            preset: .focus,
            overlay: overlay
        )

        if #available(iOS 16.2, *) {
            await ActivitiesHelper.shared.startOrUpdate(settings: SettingsStore.shared.settings, isConnected: NEConfigurationService.shared.isConnected)
        }
        await ConnectedViewController.shared.set(state: .main)
        return .result()
    }
}
