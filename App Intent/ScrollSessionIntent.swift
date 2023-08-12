//
//  ScrollSessionIntent.swift
//  slowdown
//
//  Created by Sean Lee on 8/10/23.
//

import AppIntents
import Controllers
import Logging
import AppHelpers

public struct ScrollSessionIntent: AppIntent, LiveActivityIntent {
    public static var title: LocalizedStringResource = "Start session"
    public static var description = IntentDescription("Start a 30 second social media session.")
    
    public static var openAppWhenRun: Bool = true

    var logger = Logger(label: "industries.strange.slowdown.ScrollSessionIntent")

    public init() {
    }

    public func perform() async throws -> some IntentResult {
        logger.info("ScrollSessionIntent.perform")
        await ScrollSessionViewController.shared.setOpen()
        return .result()
    }
}
