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

public extension Proxyservice_ScheduleSettings {
    // TODO: surface below Settings menu entry in a footer
    var summary: String {
        // "Detox mode on all the time."
        // "Scheduled
        ""
    }
}

public extension Proxyservice_ScheduleDay {
    var summary: String {
        if !enabled {
            return "—"
        }
        if from.hour == to.hour, from.minute == to.minute {
            return "Allowed all day"
        }
        return "\(from.summary) - \(to.summary)"
    }

    var detailSummary: AttributedString {
        if !enabled {
            return try! AttributedString(markdown: "Detox mode on **all day**.")
        }
        if from.hour == to.hour, from.minute == to.minute {
            return try! AttributedString(markdown: "Social media **allowed all day**.")
        }
        return try! AttributedString(markdown: "Social media **allowed from \(from.summary) - \(to.summary)**.")
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
