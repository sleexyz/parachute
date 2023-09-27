//
//  File.swift
//
//
//  Created by Sean Lee on 9/26/23.
//

import Foundation
@testable import Models
import ProxyService
import XCTest

final class RuleEvaluatorTests: XCTestCase {
    let ruleEvaluator = RuleEvaluator.shared

    override func setUpWithError() throws {}

    override func tearDownWithError() throws {}

    func testScheduleOffDefaultsOn() throws {
        let settings = Proxyservice_Settings.defaultSettings
        XCTAssertEqual(
            ruleEvaluator.determineMode(
                rules: RuleSet(schedule: settings.schedule),
                context: RuleContext(
                    // 8:00 PM
                    now: Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!
                )
            ),
            Mode.quiet,
            "Should default settings to quiet mode"
        )
    }

    func testScheduleEveryDay() throws {
        var settings = Proxyservice_Settings.defaultSettings
        settings.schedule.enabled = true
        settings.schedule.scheduleType = .everyDay
        settings.schedule.everyDay.from.hour = 20
        settings.schedule.everyDay.to.hour = 22

        let rules = RuleSet(
            schedule: settings.schedule
        )

        // Boundary
        XCTAssertEqual(
            ruleEvaluator.determineMode(
                rules: rules,
                context: RuleContext(
                    now: Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!
                )
            ),
            Mode.free,
            "Should allow breaks when schedule is on for every day schedules"
        )

        XCTAssertEqual(
            ruleEvaluator.determineMode(
                rules: rules,
                context: RuleContext(
                    now: Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date())!
                )
            ),
            Mode.quiet,
            "Should still be in quiet mode outside of schedule for every day schedules"
        )

        XCTAssertEqual(
            ruleEvaluator.determineMode(
                rules: rules,
                context: RuleContext(
                    now: Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date())!
                )
            ),
            Mode.quiet,
            "Should go back to quiet mode right when at the end of the scheduled period"
        )
    }

    func testScheduleEveryDayReversed() throws {
        var settings = Proxyservice_Settings.defaultSettings
        settings.schedule.enabled = true
        settings.schedule.scheduleType = .everyDay
        settings.schedule.everyDay.from.hour = 22
        settings.schedule.everyDay.to.hour = 20

        // Should be able to scroll all the time except for 8:00 PM - 10:00 PM

        let rules = RuleSet(
            schedule: settings.schedule
        )

        XCTAssertEqual(
            ruleEvaluator.determineMode(
                rules: rules,
                context: RuleContext(
                    now: Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!
                )
            ),
            Mode.quiet,
            "Should be in quiet mode outside of a reversed schedule for every day schedules"
        )

        XCTAssertEqual(
            ruleEvaluator.determineMode(
                rules: rules,
                context: RuleContext(
                    now: Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date())!
                )
            ),
            Mode.free,
            "Should allow breaks within a reversed schedule for every day schedules"
        )

        XCTAssertEqual(
            ruleEvaluator.determineMode(
                rules: rules,
                context: RuleContext(
                    now: Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date())!
                )
            ),
            Mode.free,
            "Should allow breaks within a reversed schedule for every day schedules"
        )
    }
}
