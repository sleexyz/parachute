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
    func getID() -> String {
        return Pause().id
    }
    func makeCard() -> some View {
        WiredPauseCard()
    }
}

struct PauseCard: View {
    @Environment(\.colorScheme) var scheme: ColorScheme
    var body: some View {
        Card(
            title: "Disable",
            caption: "Disconnect from VPN for 1 hour",
            backgroundColor: .clear.opacity(0.5),
            material: .ultraThinMaterial
        ) {
        }.foregroundColor(scheme == .light ? .black : .white)
    }
}

struct WiredPauseCard: View {
    @EnvironmentObject var vpnLifecycleManager: VPNLifecycleManager
    @EnvironmentObject var profileManager: ProfileManager
    @Environment(\.namespace) var namespace: Namespace.ID
    var body: some View {
        PauseCard()
            .onTapGesture {
                if !profileManager.presetSelectorOpen {
                    profileManager.presetSelectorOpen = true
                    return
                }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                vpnLifecycleManager.pauseConnection()
            }
    }
}
