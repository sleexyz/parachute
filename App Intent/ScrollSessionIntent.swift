//
//  ScrollSessionIntent.swift
//  slowdown
//
//  Created by Sean Lee on 8/10/23.
//

import AppHelpers
import AppIntents
import Controllers
import OSLog

public struct ScrollSessionIntent: AppIntent, LiveActivityIntent {
    public static var title: LocalizedStringResource = "Start session"
    public static var description = IntentDescription("Start a scrolling session.")

    public static var openAppWhenRun: Bool = true

    var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ScrollSessionIntent")

    public init() {}

    public func perform() async throws -> some IntentResult {
        logger.info("ScrollSessionIntent.perform")
        await ConnectedViewController.shared.set(state: .scrollSession)
        return .result()
    }
}
