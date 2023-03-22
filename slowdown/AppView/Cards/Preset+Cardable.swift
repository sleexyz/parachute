//
//  Preset+Cardable.swift
//  slowdown
//
//  Created by Sean Lee on 2/22/23.
//

import Foundation
import ProxyService
import SwiftUI

extension Preset: Cardable {
    func _makeCard(content: @escaping () -> AnyView) -> some View {
        WiredPresetCard(preset: self) {
            content()
        }
    }
    func getID() -> String {
        self.id
    }
    func getExpandedBody() -> AnyView {
        if let body = self.expandedBody {
            return AnyView(body)
        }
        return AnyView(EmptyView())
    }
}

struct WiredPresetCard<Content: View>: View {
    @EnvironmentObject var vpnLifecycleManager: VPNLifecycleManager
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var stateController: StateController
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.namespace) var namespace: Namespace.ID
    
    
    var preset: Preset
    
    var content: () -> Content
    
    var isActive: Bool {
        preset.presetData.id == settingsStore.activePreset.id
    }
    
    var expanded: Bool {
        isActive && !profileManager.presetSelectorOpen
    }
    
    var badgeText: String? {
//        if preset.badgeText == "∞" && !profileManager.presetSelectorOpen {
//            return nil
//        }
//        if !profileManager.presetSelectorOpen {
//            return nil
//        }
        return preset.badgeText
    }
    
    
    @ViewBuilder
    var card: some View {
        Card(
            title: preset.name,
            icon: preset.icon,
            badgeText: badgeText,
            caption: preset.description,
            backgroundColor: preset.mainColor,
            material: .ultraThinMaterial,
            id: preset.id
//            id: preset.name // HACK to animate when id is same but name changes
        ) {
            content()
        }
    }
    

    var body: some View {
        card
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                if !profileManager.presetSelectorOpen {
                    profileManager.presetSelectorOpen = true
                    return
                }
                if !isActive {
                    if preset.presetData.mode == .progressive {
                        stateController.heal()
                    }
                    profileManager.loadPreset(preset: preset)
//                    Task {
//                        try await Task.sleep(nanoseconds:500_000_000)
                    profileManager.presetSelectorOpen = false
                    profileManager.profileSelectorOpen = false
//                    }
                } else {
                    profileManager.presetSelectorOpen = false
                    profileManager.profileSelectorOpen = false
                }
            }
    }
}
