//
//  AppIntent.swift
//  SlowdownWidget
//
//  Created by Sean Lee on 8/2/23.
//

import WidgetKit
import AppIntents
import Controllers

@available(iOS 17.0, *)
struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")

    // An example configurable parameter.
    @Parameter(title: "Favorite Emoji", default: "😃")
    var favoriteEmoji: String
}
