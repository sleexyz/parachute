import AppIntents
import Controllers
import Logging
import AppHelpers

public struct StartSessionIntent: AppIntent, LiveActivityIntent {
    public static var title: LocalizedStringResource = "Start session"
    public static var description = IntentDescription("Start a 30 second social media session.")
    // public static var openAppWhenRun: Bool = true
    public static var openAppWhenRun: Bool = false

    var logger = Logger(label: "industries.strange.slowdown.StartSessionIntent")

    public init() {
    }

    public func perform() async throws -> some IntentResult {
        logger.info("StartSessionIntent.perform")
        guard let profileManager = ProfileManager.shared else  {
            throw MyIntentError.message("ProfileManager not initialized")
        }
        try await profileManager.loadPreset(
            preset: ProfileManager.presetDefaults["focus"]!,
            overlay: ProfileManager.presetDefaults["relax"]!
        )
        if #available(iOS 16.2, *) {
            await ActivitiesHelper.shared.update(settings: SettingsStore.shared.settings)
        }
        return .result()
    }
}

enum MyIntentError: Swift.Error, CustomLocalizedStringResourceConvertible {
    case general
    case message(_ message: String)

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case let .message(message): return "Error: \(message)"
        case .general: return "My general error"
        }
    }
}
