//
//  PauseCard.swift
//  slowdown
//
//  Created by Sean Lee on 2/22/23.
//

import Controllers
import Foundation
import SwiftUI

struct Pause {
    var id = "__pause"
}

extension Pause: Cardable {
    func getExpandedBody() -> AnyView {
        AnyView(EmptyView())
    }

    func getID() -> String {
        Pause().id
    }

    func _makeCard(content: @escaping () -> AnyView) -> some View {
        WiredPauseCard(id: getID()) {
            content()
        }
    }
}

struct WiredPauseCard<Content: View>: View {
    @EnvironmentObject var vpnLifecycleManager: VPNLifecycleManager
    @EnvironmentObject var profileManager: ProfileManager
    @Environment(\.colorScheme) var scheme: ColorScheme
    @Environment(\.namespace) var namespace: Namespace.ID
    var id: String
    var content: () -> Content
    var body: some View {
        Card(
            title: "Disable",
            badgeText: "1 HOUR",
            caption: "Temporarily disconnect from VPN",
            material: .ultraThinMaterial.opacity(0.02),
            id: id
        ) {
            content()
        }
        .foregroundColor(scheme == .light ? .black : .white)
        .onTapGesture {
            if !profileManager.presetSelectorOpen {
                profileManager.presetSelectorOpen = true
                return
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            vpnLifecycleManager.pauseConnection(until: nil)
        }
    }
}
