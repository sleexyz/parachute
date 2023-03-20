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
    func makeCard() -> some View {
        WiredPresetCard(preset: self)
    }
    func getID() -> String {
        self.id
    }
}

struct WiredPresetCard: View {
    @EnvironmentObject var vpnLifecycleManager: VPNLifecycleManager
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var stateController: StateController
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.namespace) var namespace: Namespace.ID
    
    var preset: Preset
    
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
            material: .regularMaterial,
            id: preset.id
        ) {
        }
    }
    

    var body: some View {
        card
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//                withAnimation {
                    if !profileManager.presetSelectorOpen {
                        profileManager.presetSelectorOpen = true
                        return
                    }
                    profileManager.presetSelectorOpen = false
                    if !isActive {
                        profileManager.loadPreset(preset: preset)
                        if preset.presetData.mode == .progressive {
                            stateController.heal()
                        }
                    }
//                }
            }
    }
}
