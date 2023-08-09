//
//  SlowdownWidget.swift
//  SlowdownWidget
//
//  Created by Sean Lee on 8/2/23.
//

import WidgetKit
import SwiftUI
import Controllers
import LoggingOSLog
import Logging
import CommonLoaders

struct Provider: AppIntentTimelineProvider {
    let logger = Logger(label: "industries.strange.slowdown.SlowdownWidget")

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        do {
            try SettingsStore.shared.load()
        } catch {
            logger.error("error loading settings: \(error)")
        }
        return SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        entries.append(SimpleEntry(date: Date(), configuration: configuration))

        try? SettingsStore.shared.load()
        if SettingsStore.shared.settings.hasOverlay {
            let expiry = SettingsStore.shared.settings.overlay.expiry.date
            let components = DateComponents(second: 0)
            let futureDate = Calendar.current.date(byAdding: components, to: expiry)!
            let entry = SimpleEntry(date: futureDate, configuration: configuration)
            entries.append(entry)
            return Timeline(entries: entries, policy: .atEnd)
        }

        return Timeline(entries: entries, policy: .never)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct SlowdownWidgetEntryView : View {
    var entry: Provider.Entry
    @EnvironmentObject private var profileManager: ProfileManager
    @EnvironmentObject private var settingsStore: SettingsStore

    var logger = Logger(label: "industries.strange.slowdown.SlowdownWidgetEntryView")

    var body: some View {
        let _ = logger.info("rendering widget entry view, \(profileManager.activePreset.id)")
        VStack {
            if profileManager.activePreset.id == "focus" {
                Button(intent: StartSession()) {
                    Text("Start scroll break 🍪")
                } 
            } else {
                let components = DateComponents(second: 0)
                let futureDate = Calendar.current.date(byAdding: components, to: settingsStore.settings.overlay.expiry.date)!
                Text(futureDate, style: .timer)
            }
        }
    }
}

struct SlowdownWidget: Widget {
    let kind: String = "industries.strange.slowdown.SlowdownWidget"

    init() {
        LoggingSystem.bootstrap(LoggingOSLog.init)
        Task {
            await VPNConfigurationService.shared.load()
        }
    }

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            ControllersLoader {
                SlowdownWidgetEntryView(entry: entry)
                    .environmentObject(VPNConfigurationService.shared)
                    .containerBackground(.fill.tertiary, for: .widget)
            }
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemLarge) {
    SlowdownWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley)
    SimpleEntry(date: .now, configuration: .starEyes)
}
