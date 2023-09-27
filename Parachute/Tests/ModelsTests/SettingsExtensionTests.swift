import Foundation
@testable import Models
import ProxyService
import XCTest

final class ScheduleSettingsSummaryTests: XCTestCase {
    let ruleEvaluator = RuleEvaluator.shared

    override func setUpWithError() throws {}

    override func tearDownWithError() throws {}

    func testScheduleOffSummary() throws {
        var schedule = Proxyservice_Settings.defaultSettings.schedule
        schedule.enabled = false
        XCTAssertEqual(
            schedule.summary,
            "Always Quiet"
        )
    }

    func testScheduleOnSummary() throws {
        var schedule = Proxyservice_Settings.defaultSettings.schedule
        schedule.enabled = true
        XCTAssertEqual(
            schedule.summary,
            "Schedule"
        )
    }
}
