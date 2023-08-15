//
//  SlowdownWidgetView.swift
//  slowdown
//
//  Created by Sean Lee on 8/11/23.
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

@available(iOS 17.0, *)
struct SlowdownWidgetView : View {
    var settings: Proxyservice_Settings

    var logger = Logger(label: "industries.strange.slowdown.SlowdownWidgetView")

    var statusMessage: String {
        if settings.changeMetadata.reason == "Overlay expired" && settings.changeMetadata.timestamp.date.timeIntervalSinceNow.magnitude < 1 * 60 {
            return "Session ended"
        }
        return "Slowing Active"
    }

    var body: some View {
        let _ = logger.info("rendering widget entry view, \(settings.activePreset.id)")
        VStack {
            if settings.activePreset.id == Proxyservice_Preset.focus.id {
                HStack {
                    Button(intent: ScrollSessionIntent()) {
                        Image(systemName: "play.fill")
                        Text("Scroll for \(Int(Preset.scrollSession.overlayDurationSecs!  / 60)) min")
                    }
                    .buttonStyle(.bordered)
                    .tint(.parachuteOrange)

//                    Button(intent: QuickBreakIntent()) {
//                        //Image(systemName: "play.fill")
//                        Text("\(Int(Preset.quickBreak.overlayDurationSecs!))s")
//                    }
//                    .buttonStyle(.bordered)
//                    .tint(.secondaryFill)
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
        .blendMode(.lighten)
    }
}