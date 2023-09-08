//
//  SlowdownWidgetProvider.swift
//  SlowdownWidgetExtension
//
//  Created by Sean Lee on 8/26/23.
//

import Controllers
import Foundation
import OSLog
import WidgetKit

struct SlowdownWidgetProvider: TimelineProvider {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SlowdownWidgetProvider")

    func placeholder(in _: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), settings: .defaultSettings, isConnected: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        Task {
            let entry = await getSnapshot(in: context)
            completion(entry)
        }
    }

    func getSnapshot(in _: Context) async -> SimpleEntry {
        try? SettingsStore.shared.load()
        await NEConfigurationService.shared.load()
        let isConnected = NEConfigurationService.shared.isConnected

        return SimpleEntry(date: Date(), settings: SettingsStore.shared.settings, isConnected: isConnected)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        Task {
            let entry = await getTimeline(in: context)
            completion(entry)
        }
    }

    func getTimeline(in _: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        try? SettingsStore.shared.load()
        await NEConfigurationService.shared.load()
        let isConnected = NEConfigurationService.shared.isConnected

        entries.append(SimpleEntry(date: Date(), settings: SettingsStore.shared.settings, isConnected: isConnected))

        if SettingsStore.shared.settings.hasOverlay {
            let expiry = SettingsStore.shared.settings.overlay.expiry.date
            let components = DateComponents(second: 0)
            let futureDate = Calendar.current.date(byAdding: components, to: expiry)!
            let entry = SimpleEntry(date: futureDate, settings: SettingsStore.shared.settings, isConnected: isConnected)
            entries.append(entry)
            return Timeline(entries: entries, policy: .atEnd)
        }

        return Timeline(entries: entries, policy: .never)
    }
}
