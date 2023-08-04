//
//  AppIntent.swift
//  SlowdownWidget
//
//  Created by Sean Lee on 8/2/23.
//

import WidgetKit
import AppIntents

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
        return .result()
    }
}
