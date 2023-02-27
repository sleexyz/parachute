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
}

struct WiredPresetCard: View {
    @EnvironmentObject var vpnLifecycleManager: VPNLifecycleManager
    @EnvironmentObject var presetManager: PresetManager
    @EnvironmentObject var settingsStore: SettingsStore
    
    var preset: Preset
    
    var isActive: Bool {
        preset.presetData.id == settingsStore.settings.activePreset.id
    }
    
    var expanded: Bool {
        isActive && presetManager.state == .cardOpened
    }
    
    var model: PresetViewModel {
                PresetViewModel(
                presetData: Binding(
                    get: {
                        return preset.presetData
                    },
                    set: { _ in }
                ),
                preset: PresetManager.getPreset(id: preset.presetData.id)
            )
        
    }
    
    @ViewBuilder
    var card: some View {
        if preset.presetData.mode == .progressive {
            ProgressiveCard(model: model) {
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
