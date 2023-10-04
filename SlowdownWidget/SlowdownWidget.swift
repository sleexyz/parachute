//
//  SlowdownWidget.swift
//  SlowdownWidget
//
//  Created by Sean Lee on 8/2/23.
//

import Activities
import CommonLoaders
import CommonViews
import Controllers
import Models
import OSLog
import ProxyService
import SwiftProtobuf
import SwiftUI
import WidgetKit

struct SimpleEntry: TimelineEntry {
    let date: Date
    let settings: Proxyservice_Settings
    let isConnected: Bool
}

struct SlowdownWidget: Widget {
    let kind: String = "industries.strange.slowdown.SlowdownWidget"

    init() {
        Fonts.registerFonts()
        // Task {
        //     await NEConfigurationService.shared.load()
        // }
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SlowdownWidgetProvider()) { entry in
            ControllersLoader {
                SlowdownWidgetView(settings: entry.settings, isConnected: entry.isConnected)
                    .widgetBackground(Color.background)
            }
        }
    }
}

extension View {
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
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

// #Preview(as: .systemLarge) {
//    SlowdownWidget()
// } timeline: {
//    SimpleEntry(date: .now, settings: .focus, isConnected: true)
//    SimpleEntry(date: .now, settings: .relax, isConnected: true)
//    SimpleEntry(date: .now, settings: .relax, isConnected: false)
// }
