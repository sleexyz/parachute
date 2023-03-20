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
        WiredPauseCard(id: getID())
    }
}

struct WiredPauseCard: View {
    @EnvironmentObject var vpnLifecycleManager: VPNLifecycleManager
    @EnvironmentObject var profileManager: ProfileManager
    @Environment(\.colorScheme) var scheme: ColorScheme
    @Environment(\.namespace) var namespace: Namespace.ID
    var id: String
    var body: some View {
        Card(
            title: "Disable",
            caption: "Disconnect from VPN for 1 hour",
            backgroundColor: .clear.opacity(0.5),
            material: .ultraThinMaterial,
            id: id
        ) {
        }
            .foregroundColor(scheme == .light ? .black : .white)
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
