//
//  Settings Extensions.swift
//  Common
//
//  Created by Sean Lee on 2/15/23.
//
import Foundation
import ProxyService
import SwiftUI

public extension String {
    static var vendorConfigurationKey = "slowdown-settings"
}

public extension Proxyservice_ScheduleSettings {
    var summary: AttributedString {
        if scheduleType == .everyDay {
            return AttributedString(everyDay.detailSummary(day: nil))
        } else {
            var str = AttributedString()
            let days: [Proxyservice_ScheduleDay] = (0 ..< 7).map { self.days[Int32($0)]! }
            if days.first(where: { !$0.isAllDay }) == nil {
                str.append(AttributedString("Quiet time on all day"))
            } else {
                str.append(AttributedString("Free social media use from\n"))
            }
            for i in 0 ..< 7 {
                let day = days[i]
                if !day.isAllDay {
                    str.append(AttributedString("• \(day.durationSummary(day: i))"))
                    if i < 6 {
                        str.append(AttributedString("\n"))
                    }
                }
            }
            return str
        }
    }
}

public extension Proxyservice_ScheduleDay {
    var summary: AttributedString {
        if isAllDay {
            return try! AttributedString(markdown: "**\(defaultVerb.verb)**")
        }
        let now = Date()
        let superscript = toDate(now: now) < fromDate(now: now) ? "⁺¹" : ""

        return try! AttributedString(
            markdown: """
            **\(defaultVerb.opposite.verb)** \(from.summary)-\(to.summary)\(superscript)
            """,
            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )
    }

    static func partialSummary(verb: Proxyservice_RuleVerb) -> String {
        "\(verb.verb) \(verb == .allow ? "social media use" : "time")"
    }

    func detailSummary(day: Int?) -> String {
        if isAllDay {
            return """
            \(Proxyservice_ScheduleDay.partialSummary(verb: defaultVerb)) on all day
            """
        }
        // return """
        // \(Proxyservice_ScheduleDay.partialSummary(verb: defaultVerb)) for most of the day.
        // \(Proxyservice_ScheduleDay.partialSummary(verb: defaultVerb.opposite)) from \(from.summary)-\(to.summary).
        // """

        return """
        \(Proxyservice_ScheduleDay.partialSummary(verb: defaultVerb.opposite)) from\(durationSummary(day: day))
        """
    }

    func durationSummary(day: Int?) -> String {
        var fromDayString = ""
        var toDayString = ""
        if let day {
            var toDay = day
            let now = Date()
            if fromDate(now: now) >= toDate(now: now) {
                toDay = (day + 1) % 7
            }
            fromDayString = " \(Proxyservice_ScheduleDay.getName(day: day))"
            toDayString = " \(Proxyservice_ScheduleDay.getName(day: toDay))"
        }

        return "\(fromDayString) \(from.summary) to\(toDayString) \(to.summary)"
    }

    static func getName(day: Int) -> String {
        let names = [
            "Sunday",
            "Monday",
            "Tuesday",
            "Wednesday",
            "Thursday",
            "Friday",
            "Saturday",
        ]

        return names[day]
    }

    func fromDate(now: Date) -> Date {
        Calendar.current.date(bySettingHour: Int(from.hour), minute: Int(from.minute), second: 0, of: now)!
    }

    func toDate(now: Date) -> Date {
        Calendar.current.date(bySettingHour: Int(to.hour), minute: Int(to.minute), second: 0, of: now)!
    }

    func forToday(now: Date) -> (Date, Date, Bool) {
        let fromDate = fromDate(now: now)
        var toDate = toDate(now: now)
        var reversed = false

        // TODO: test equal case
        if fromDate >= toDate {
            toDate = Calendar.current.date(byAdding: .day, value: 1, to: toDate)!
            reversed = true
        }

        return (fromDate, toDate, reversed)
    }

    var duration: TimeInterval {
        let (from, to, _) = forToday(now: Date())
        return to.timeIntervalSince(from)
    }
}

public extension Proxyservice_ScheduleTime {
    var summary: String {
        // Adjust from 24 hour time
        // Use Dateformatter to get the correct time format:

        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let date = Calendar.current.date(bySettingHour: Int(hour), minute: Int(minute), second: 0, of: Date())!
        return formatter.string(from: date)
    }
}

public extension Proxyservice_Settings {
    static var defaultSettings: Proxyservice_Settings {
        var settings = Proxyservice_Settings()
        SettingsMigrations.setDefaults(settings: &settings)
        return settings
    }
}

public extension Proxyservice_Settings {
    var activePreset: Proxyservice_Preset {
        if expiryMechanism == .overlayTimer {
            if Date.now < overlay.expiry.date {
                return overlay.preset
            }
        } else {
            if hasOverlay {
                return overlay.preset
            }
        }
        return defaultPreset
    }

    var isDisabled: Bool {
        Date.now < disabledUntil.date
    }

    var isInScrollSession: Bool {
        activePreset.baseRxSpeedTarget == .infinity
    }

    func isAppEnabled(app: Proxyservice_AppType) -> Bool {
        apps[Int32(app.rawValue)] ?? false
    }

    mutating func setAppEnabled(app: Proxyservice_AppType, value: Bool) {
        apps[Int32(app.rawValue)] = value
    }

    var filterModeDecision: FilterModeDecision {
        let rules = RuleSet(schedule: schedule)
        let context = RuleContext(now: Date())
        let mode = RuleEvaluator.shared.determineMode(rules: rules, context: context)

        switch mode {
        case .quiet:
            return .quiet
        case .free:
            return .free(reason: .schedule)
        }
    }
}

extension Proxyservice_Settings: CodableMessage {}

public extension Proxyservice_RuleVerb {
    var verb: String {
        switch self {
        case .block:
            "Quiet"
        default:
            "Free"
        }
    }

    var opposite: Proxyservice_RuleVerb {
        switch self {
        case .block:
            .allow
        default:
            .block
        }
    }
}
