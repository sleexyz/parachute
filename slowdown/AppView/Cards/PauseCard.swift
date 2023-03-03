//
//  PauseCard.swift
//  slowdown
//
//  Created by Sean Lee on 2/22/23.
//

import Foundation
import SwiftUI

struct PauseCard: View {
    @Environment(\.colorScheme) var scheme: ColorScheme
    var body: some View {
        Card(
            title: "Pause",
            caption: "Disconnects from VPN for 1 hour",
            backgroundColor: Color.clear
        ) {
        }.foregroundColor(scheme == .light ? .black : .white)
    }
}

struct WiredPauseCard: View {
    @EnvironmentObject var vpnLifecycleManager: VPNLifecycleManager
    @EnvironmentObject var presetManager: PresetManager
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
