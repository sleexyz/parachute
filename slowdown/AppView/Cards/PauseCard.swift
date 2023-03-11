//
//  PauseCard.swift
//  slowdown
//
//  Created by Sean Lee on 2/22/23.
//

import Foundation
import SwiftUI

struct Pause {
    var id = "__pause"
}

extension Pause: Cardable {
    func makeCard() -> some View {
        WiredPauseCard()
    }
}

struct PauseCard: View {
    @Environment(\.colorScheme) var scheme: ColorScheme
    var body: some View {
        Card(
            title: "Pause",
            caption: "Disconnects from VPN for 1 hour",
            backgroundColor: .clear.opacity(0.5),
            material: .ultraThinMaterial
        ) {
        }.foregroundColor(scheme == .light ? .black : .white)
    }
}

struct WiredPauseCard: View {
    @EnvironmentObject var vpnLifecycleManager: VPNLifecycleManager
    @EnvironmentObject var presetManager: ProfileManager
    var body: some View {
        PauseCard()
            .onTapGesture {
                if !presetManager.open {
                    presetManager.open = true
                    return
                }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                vpnLifecycleManager.pauseConnection()
            }
    }
}
