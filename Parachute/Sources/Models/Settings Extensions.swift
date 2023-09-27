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

extension Proxyservice_Preset: Identifiable {
    public typealias ID = String
}

public extension Proxyservice_ScheduleDay {
    var summary: AttributedString {
        if isAllDay {
            return try! AttributedString(markdown: "**\(defaultVerb.verb)**")
        }

        return try! AttributedString(
            markdown: "**\(defaultVerb.verb)**\n**\(defaultVerb.opposite.verb)** \(from.summary)-\(to.summary)",
            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )
    }

    static func partialSummary(verb: Proxyservice_RuleVerb) -> String {
        "\(verb.verb)ing social media\(verb == .allow ? " usage" : "")"
    }

    var detailSummary: String {
        if isAllDay {
            return """
            \(Proxyservice_ScheduleDay.partialSummary(verb: defaultVerb)) all day.
            """
        }
        return """
        \(Proxyservice_ScheduleDay.partialSummary(verb: defaultVerb)) for most of the day.
        \(Proxyservice_ScheduleDay.partialSummary(verb: defaultVerb.opposite)) from \(from.summary)-\(to.summary).
        """
    }

    func forToday(now _: Date) -> (Date, Date, Bool) {
        let fromDate = Calendar.current.date(bySettingHour: Int(from.hour), minute: Int(from.minute), second: 0, of: Date())!
        var toDate = Calendar.current.date(bySettingHour: Int(to.hour), minute: Int(to.minute), second: 0, of: Date())!

        var reversed = false

        if toDate < fromDate {
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
        if Date.now < overlay.expiry.date {
            return overlay.preset
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
