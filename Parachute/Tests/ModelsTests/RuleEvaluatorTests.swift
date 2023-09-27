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
        settings.schedule.scheduleType = .everyDay
        settings.schedule.everyDay.from.hour = 20
        settings.schedule.everyDay.to.hour = 22
        settings.schedule.everyDay.isAllDay = false

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
        settings.schedule.scheduleType = .everyDay
        settings.schedule.everyDay.from.hour = 22
        settings.schedule.everyDay.to.hour = 20
        settings.schedule.everyDay.isAllDay = false

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

    func makeDate(hour: Int, dayIndex: Int = 0) -> Date {
        var dateComponents = DateComponents()
        dateComponents.day = 4 + (dayIndex % 7)
        dateComponents.month = 1
        dateComponents.year = 1970
        dateComponents.hour = hour
        return Calendar.current.date(from: dateComponents)!
    }

    func testScheduleCustomDays() throws {
        var settings = Proxyservice_Settings.defaultSettings
        settings.schedule.scheduleType = .customDays

        for i in 0 ..< 7 {
            var day = Proxyservice_ScheduleDay()
            day.isAllDay = true
            settings.schedule.days[Int32(i)] = day
        }

        settings.schedule.days[0]!.isAllDay = false
        settings.schedule.days[0]!.from.hour = 12
        settings.schedule.days[0]!.to.hour = 20

        let rules = RuleSet(
            schedule: settings.schedule
        )

        XCTAssertEqual(
            ruleEvaluator.determineMode(
                rules: rules,
                context: RuleContext(
                    now: makeDate(hour: 12, dayIndex: 0)
                )
            ),
            Mode.free,
            "Should be in free mode on Sunday from 12:00 PM - 8:00 PM"
        )
        XCTAssertEqual(
            ruleEvaluator.determineMode(
                rules: rules,
                context: RuleContext(
                    now: makeDate(hour: 20, dayIndex: 0)
                )
            ),
            Mode.quiet,
            "Should be in quiet mode on Sunday after 8:00 PM"
        )
        XCTAssertEqual(
            ruleEvaluator.determineMode(
                rules: rules,
                context: RuleContext(
                    now: makeDate(hour: 12, dayIndex: 1)
                )
            ),
            Mode.quiet,
            "Should be in quiet mode on Monday"
        )
    }

    func testScheduleCustomDaysOverflow() throws {
        var settings = Proxyservice_Settings.defaultSettings
        settings.schedule.scheduleType = .customDays

        for i in 0 ..< 7 {
            var day = Proxyservice_ScheduleDay()
            day.isAllDay = true
            settings.schedule.days[Int32(i)] = day
        }

        settings.schedule.days[0]!.isAllDay = false
        settings.schedule.days[0]!.from.hour = 20
        settings.schedule.days[0]!.to.hour = 2 // 2am Monday

        let rules = RuleSet(
            schedule: settings.schedule
        )

        XCTAssertEqual(
            ruleEvaluator.determineMode(
                rules: rules,
                context: RuleContext(
                    now: makeDate(hour: 23, dayIndex: 0)
                )
            ),
            Mode.free,
            "Should be in quiet mode on Sunday 11:00 PM"
        )

        XCTAssertEqual(
            ruleEvaluator.determineMode(
                rules: rules,
                context: RuleContext(
                    now: makeDate(hour: 0, dayIndex: 1)
                )
            ),
            Mode.free,
            "Should be in free mode on Monday 12:00 AM"
        )

        XCTAssertEqual(
            ruleEvaluator.determineMode(
                rules: rules,
                context: RuleContext(
                    now: makeDate(hour: 0, dayIndex: 1)
                )
            ),
            Mode.free,
            "Should be in quiet mode on Monday 2:00 AM"
        )

        XCTAssertEqual(
            ruleEvaluator.determineMode(
                rules: rules,
                context: RuleContext(
                    now: makeDate(hour: 0, dayIndex: 2)
                )
            ),
            Mode.quiet,
            "Should not be in freemode on Tueday 12:00 AM"
        )
    }
}
