//
//  SlowdownWidget.swift
//  SlowdownWidget
//
//  Created by Sean Lee on 8/2/23.
//

import WidgetKit
import SwiftUI
import Controllers
import OSLog
import CommonLoaders
import Activities
import Models
import ProxyService
import SwiftProtobuf
import CommonViews


struct SimpleEntry: TimelineEntry {
    let date: Date
    let settings: Proxyservice_Settings
}


struct SlowdownWidget: Widget {
    let kind: String = "industries.strange.slowdown.SlowdownWidget"

    init() {
        Fonts.registerFonts()
        Task {
            await NEConfigurationService.shared.load()
        }
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SlowdownWidgetProvider()) { entry in
            ControllersLoader {
                SlowdownWidgetView(settings: entry.settings)
                    .environmentObject(NEConfigurationService.shared)
                    //.containerBackground(Color.background, for: .widget)
            }
        }
//        if #available(iOSApplicationExtension 17.0, *) {
//             AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: SlowdownWidgetProvider()) { entry in
//                ControllersLoader {
//                    SlowdownWidgetView(settings: entry.settings)
//                        .environmentObject(NEConfigurationService.shared)
//                        .containerBackground(Color.background, for: .widget)
//                }
//            }
//        } else {
//            IntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: SiriKitIntentProvider()) { entry in
//            }
//        }
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
