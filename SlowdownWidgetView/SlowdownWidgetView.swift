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

    var statusMessage: String? {
        if settings.changeMetadata.reason == "Overlay expired" && settings.changeMetadata.timestamp.date.timeIntervalSinceNow.magnitude < 1 * 60 {
            return "Session ended"
        }
        return nil
    }

    var body: some View {
        let _ = logger.info("rendering widget entry view, \(settings.activePreset.id)")
        VStack {
            if settings.activePreset.id == Proxyservice_Preset.focus.id {
                HStack {
                    Button(intent: ScrollSessionIntent()) {
                        Image(systemName: "play.fill")
                            .foregroundColor(.white) 
                        Text("3 minutes")
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.parachuteOrange)

                    Spacer()

                    Button(intent: QuickBreakIntent()) {
                        Image(systemName: "play.fill")
                            .foregroundColor(.white) 
                        Text("\(Int(Preset.quickBreak.overlayDurationSecs!)) seconds")
                            .foregroundStyle(.white)

                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.secondaryFill)
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
                } else {
                    Text("...")
                }
            }
        }
        .foregroundStyle(.black.opacity(0.6))
        .buttonBorderShape(.capsule)
            // .blendMode(.lighten)
    }
}
