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

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct SlowdownWidgetEntryView : View {
    var entry: Provider.Entry
    @EnvironmentObject private var profileManager: ProfileManager

    var body: some View {
        VStack {
            if profileManager.activePreset.id == "focus" {
                Button(intent: StartSession()) {
                    Text("Start scroll break 🍪")
                } 
            } else {
                Text("Scroll break in progress...")
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
