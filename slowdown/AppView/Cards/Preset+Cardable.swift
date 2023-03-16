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
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.namespace) var namespace: Namespace.ID
    
    var preset: Preset
    
    var isActive: Bool {
        preset.presetData.id == settingsStore.activePreset.id
    }
    
    var expanded: Bool {
        isActive && profileManager.state == .cardOpened
    }
    
    var badge: String? {
        if profileManager.presetSelectorOpen {
            if profileManager.defaultPreset.id == preset.id {
                return  "Default"
            }
        }
        return nil
    }
    
    @ViewBuilder
    var card: some View {
        Card(
            title: preset.name,
            badge: badge,
            caption: preset.description,
            backgroundColor: preset.mainColor,
            material: .thinMaterial.opacity(preset.opacity)
        ) {
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
                withAnimation {
                    profileManager.presetSelectorOpen = false
                    if !isActive {
                        profileManager.loadOverlay(preset: preset)
                    }
                }
            }
    }
}
