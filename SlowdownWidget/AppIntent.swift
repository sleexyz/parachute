//
//  AppIntent.swift
//  SlowdownWidget
//
//  Created by Sean Lee on 8/2/23.
//

import WidgetKit
import AppIntents
import Controllers

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")

    // An example configurable parameter.
    @Parameter(title: "Favorite Emoji", default: "😃")
    var favoriteEmoji: String
}


struct StartSession: AppIntent {
    static var title: LocalizedStringResource = "Start session"
    static var description = IntentDescription("Start a 30 second social media session.")

    func perform() async throws -> some IntentResult {
        guard let profileManager = ProfileManager.shared else  {
            throw MyIntentError.message("ProfileManager not initialized")
        }
        try await profileManager.loadPreset(
            preset: ProfileManager.presetDefaults["focus"]!,
            overlay: ProfileManager.presetDefaults["relax"]!
        )
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
