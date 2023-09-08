//
//  AppIntent.swift
//  SlowdownWidget
//
//  Created by Sean Lee on 8/2/23.
//

import AppIntents
import Controllers
import WidgetKit

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")

//    // An example configurable parameter.
//    @Parameter(title: "Favorite Emoji", default: "😃")
//    var favoriteEmoji: String

    func perform() async throws -> some IntentResult {
        .result()
    }
}
