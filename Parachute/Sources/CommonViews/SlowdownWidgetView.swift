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
        HStack {
            Image(systemName: "drop.fill")
                .font(.system(.body, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(Color.parachuteOrange)
                .padding(.trailing, 4)

            Text("faucet")
                .font(.system(.body, design: .rounded))
                // .font(.custom("SpaceMono-Regular", size: 16))
                // .textCase(.uppercase)
                .fontWeight(.bold)
                .foregroundStyle(Color.parachuteOrange)
        }
    }
}

public struct SlowdownWidgetView : View {
    var settings: Proxyservice_Settings
    var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SlowdownWidgetView")

    @Namespace private var animation

    public init(settings: Proxyservice_Settings) {
        self.settings = settings
    }


    var statusMessage: String {
        if settings.changeMetadata.reason == "Overlay expired" && settings.changeMetadata.timestamp.date.timeIntervalSinceNow.magnitude < 1 * 60 {
            return "Session ended"
        }
        return "Detox Active"
    }



    public var body: some View {
        HStack(alignment: .top) {
            Logo()
                // .frame(width: 30, height: 30)
            Spacer()
            if !settings.isInScrollSession {
                Text(statusMessage)
                    .font(.subheadline.smallCaps())
                    .foregroundColor(.secondary)
                    // .matchedGeometryEffect(id: "status", in: animation)
            } else if settings.hasOverlay {
                let components = DateComponents(second: 0)
                let futureDate = Calendar.current.date(byAdding: components, to: settings.overlay.expiry.date)!
                Text(futureDate, style: .timer)
                    .font(.system(size: 36))
                    .monospacedDigit()
                    .foregroundColor(.primary.opacity(0.5))
                    // .matchedGeometryEffect(id: "status", in: animation)
                    .frame(maxWidth: 84)
                    // .foregroundColor(.parachuteOrange.opacity(0.8))
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
