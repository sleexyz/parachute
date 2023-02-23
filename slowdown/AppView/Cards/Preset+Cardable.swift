//
//  Preset+Cardable.swift
//  slowdown
//
//  Created by Sean Lee on 2/22/23.
//

import Foundation
import ProxyService
import SwiftUI

extension Proxyservice_Preset: Cardable {
    func makeCard() -> some View {
        WiredPresetCard(preset: self)
    }
}

struct WiredPresetCard: View {
    @EnvironmentObject var vpnLifecycleManager: VPNLifecycleManager
    @EnvironmentObject var presetManager: PresetManager
    @EnvironmentObject var settingsStore: SettingsStore
    
    var preset: Proxyservice_Preset
    
    var isActive: Bool {
        preset.id == settingsStore.settings.activePreset.id
    }
    
    var expanded: Bool {
        isActive && presetManager.state == .cardOpen
    }
    
    var model: PresetViewModel {
                PresetViewModel(
                preset: Binding(
                    get: {
                        return preset
                    },
                    set: { _ in }
                )
            )
        
    }
    
    @ViewBuilder
    var card: some View {
        if preset.mode == .progressive {
            ProgressiveCard(model: model) {
                if expanded {
                    VStack {
                        Spacer()
                        SlowingStatus()
                        Spacer()
                    }
                }
            }
        } else {
            FocusCard(model: model) {
            }
        }
        
    }
    
    var body: some View {
        card
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                if !presetManager.open {
                    presetManager.open = true
                    return
                }
                Task {
                    presetManager.open = false
                    if !isActive {
                        try await presetManager.loadPreset(preset: preset)
                    }
                }
            }
        
    }
}
