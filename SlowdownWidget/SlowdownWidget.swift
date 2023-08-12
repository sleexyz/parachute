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
import Activities
import Models
import ProxyService
import SwiftProtobuf
import CommonViews

struct Provider: AppIntentTimelineProvider {
    let logger = Logger(label: "industries.strange.slowdown.SlowdownWidget")

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), settings: .defaultSettings)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        try? SettingsStore.shared.load()
        return SimpleEntry(date: Date(), settings: SettingsStore.shared.settings)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        try? SettingsStore.shared.load()
        entries.append(SimpleEntry(date: Date(), settings: SettingsStore.shared.settings))

        if SettingsStore.shared.settings.hasOverlay {
            let expiry = SettingsStore.shared.settings.overlay.expiry.date
            let components = DateComponents(second: 0)
            let futureDate = Calendar.current.date(byAdding: components, to: expiry)!
            let entry = SimpleEntry(date: futureDate, settings: SettingsStore.shared.settings)
            entries.append(entry)
            return Timeline(entries: entries, policy: .atEnd)
        }

        return Timeline(entries: entries, policy: .never)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let settings: Proxyservice_Settings
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
                SlowdownWidgetView(settings: entry.settings)
                    .environmentObject(VPNConfigurationService.shared)
                    .containerBackground(.fill.tertiary, for: .widget)
            }
        }
    }
}

extension Proxyservice_Settings {
    static var focus: Proxyservice_Settings {
        Proxyservice_Settings.with {
            $0.defaultPreset = .focus
        }
    }
    
    static var relax: Proxyservice_Settings {
        Proxyservice_Settings.with {
            $0.defaultPreset = .focus
            $0.overlay = Proxyservice_Overlay.with {
                $0.preset = .relax
                $0.expiry = Google_Protobuf_Timestamp(date: Date(timeIntervalSinceNow: 30))
            }
        }
    }
}


#Preview(as: .systemLarge) {
    SlowdownWidget()
} timeline: {
    SimpleEntry(date: .now, settings: .focus)
    SimpleEntry(date: .now, settings: .relax)
}
