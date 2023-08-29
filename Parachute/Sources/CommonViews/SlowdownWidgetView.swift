//
//  SlowdownWidgetView.swift
//  slowdown
//
//  Created by Sean Lee on 8/11/23.
//

import WidgetKit
import SwiftUI
import Controllers
import CommonLoaders
import Activities
import Models
import ProxyService
import SwiftProtobuf
import OSLog

struct Logo: View {
    var body: some View {
        Text("parachute")
            .foregroundStyle(Color.parachuteOrange)
    }
}

public struct SlowdownWidgetView : View {
    var settings: Proxyservice_Settings
    var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SlowdownWidgetView")

    public init(settings: Proxyservice_Settings) {
        self.settings = settings
    }


    var statusMessage: String {
        if settings.changeMetadata.reason == "Overlay expired" && settings.changeMetadata.timestamp.date.timeIntervalSinceNow.magnitude < 1 * 60 {
            return "Session ended"
        }
        return "Active"
    }

    public var body: some View {
        VStack {
            if settings.activePreset.id == Proxyservice_Preset.focus.id {
                HStack {
                    Logo()
                        .frame(width: 30, height: 30)
                    Spacer()
                    Text(statusMessage)
                        .font(.subheadline.smallCaps())
                        .foregroundColor(.secondary)
                }
            } else {
                if settings.hasOverlay {
                    let components = DateComponents(second: 0)
                    let futureDate = Calendar.current.date(byAdding: components, to: settings.overlay.expiry.date)!
                    HStack {
                        Text("Session ends in")
                        Text(futureDate, style: .timer)
                            .frame(maxWidth: 40)
                    }
                    .foregroundColor(.secondary)
                } else {
                    Text("...")
                }
            }
        }
        .buttonBorderShape(.capsule)
        .preferredColorScheme(.dark)
        .environment(\.colorScheme, .dark) // For some reason .preferredColorScheme doesn't work with widgets so we do both

    }
}
