//
//  SlowdownWidgetView.swift
//  slowdown
//
//  Created by Sean Lee on 8/11/23.
//

import Activities
import CommonLoaders
import Controllers
import Models
import OSLog
import ProxyService
import SwiftProtobuf
import SwiftUI
import WidgetKit

struct Logo: View {
    var body: some View {
        HStack {
            // Image(systemName: "drop.fill")
            //     .font(.system(.body, design: .rounded))
            //     .fontWeight(.bold)
            //     .foregroundStyle(Color.parachuteOrange)
            //     .padding(.trailing, 4)

            Text("parachute.")
                .font(.system(.body, design: .rounded))
                // .font(.custom("SpaceMono-Regular", size: 16))
                // .textCase(.uppercase)
                .fontWeight(.bold)
        }
    }
}

public struct SlowdownWidgetView: View {
    var settings: Proxyservice_Settings
    var isConnected: Bool

    var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SlowdownWidgetView")

    @Environment(\.widgetFamily) var family
    @Namespace private var animation

    public init(settings: Proxyservice_Settings, isConnected: Bool) {
        self.settings = settings
        self.isConnected = isConnected
    }

    var statusMessage: String {
        // if settings.changeMetadata.timestamp.date.timeIntervalSinceNow.magnitude < 1 * 60 {
        //     return "Session ended"
        // }
        "Quiet time."
    }

    public var body: some View {
        let layout = family == .systemSmall ? AnyLayout(VStackLayout(alignment: .leading)) : AnyLayout(HStackLayout(alignment: .top))

        layout {
            // Logo()
            //     .foregroundStyle(isConnected ? Color.parachuteOrange : Color.secondary)
            // // .frame(width: 30, height: 30)
            // Spacer()
            if !isConnected {
                Text("Disabled for 1 hour.")
                    .font(.subheadline.smallCaps())
                    .foregroundColor(.secondary)
            } else if case let .free(reason: reason) = settings.filterModeDecision {
                Text("Scheduled free time.")
                    .font(.subheadline.smallCaps())
                    .foregroundColor(.secondary)
            } else if !settings.isInScrollSession {
                Text(statusMessage)
                    .font(.subheadline.smallCaps())
                    .foregroundColor(.secondary)
            } else if settings.hasOverlay {
                if settings.expiryMechanism == .overlayTimer {
                    let components = DateComponents(second: 0)
                    let futureDate = Calendar.current.date(byAdding: components, to: settings.overlay.expiry.date)!
                    Text(futureDate, style: .timer)
                        .font(.system(size: 36))
                        .monospacedDigit()
                        .foregroundColor(.primary.opacity(0.5))
                        .multilineTextAlignment(family == .systemSmall ? .leading : .trailing)
                } else {
                    Text("Free time.")
                        .font(.subheadline.smallCaps())
                        .foregroundColor(.secondary)
                }
            } else {
                Text("...")
            }
        }
        .padding(.vertical, 20)
//        .frame(minHeight: settings.isInScrollSession ? 160 : 0, alignment: .top)
        .buttonBorderShape(.capsule)
        .preferredColorScheme(.dark)
        .environment(\.colorScheme, .dark) // For some reason .preferredColorScheme doesn't work with widgets so we do both
        // .animation(.spring(duration: 0.2), value: settings)
    }
}
