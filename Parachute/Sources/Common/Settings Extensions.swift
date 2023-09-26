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
            return try! AttributedString(markdown: "Detox mode **on all day**.")
        }
        if from.hour == to.hour, from.minute == to.minute {
            return try! AttributedString(markdown: "Detox mode **off all day**.")
        }
        return try! AttributedString(markdown: "Detox mode **paused from \(from.summary) - \(to.summary)**.")
    }

    var duration: TimeInterval {
        let from = Calendar.current.date(bySettingHour: Int(from.hour), minute: Int(from.minute), second: 0, of: Date())!
        var to = Calendar.current.date(bySettingHour: Int(to.hour), minute: Int(to.minute), second: 0, of: Date())!

        if to < from {
            to = Calendar.current.date(byAdding: .day, value: 1, to: to)!
        }

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
