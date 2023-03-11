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
    @EnvironmentObject var presetManager: ProfileManager
    @EnvironmentObject var settingsStore: SettingsStore
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var preset: Preset
    
    var isActive: Bool {
        preset.presetData.id == settingsStore.activePreset.id
    }
    
    var expanded: Bool {
        isActive && presetManager.state == .cardOpened
    }
    
    @ViewBuilder
    var card: some View {
        if preset.presetData.mode == .progressive {
            ProgressiveCard(preset: preset) {
            }
        } else {
            FocusCard(preset: preset) {
            }
        }
        
    }
    
    var foregroundColor: Color {
        if getLuminance(color: preset.mainColor) < 0.5 {
            return Color.white
        } else {
            return Color.black
        }
    }
    
    func getLuminance(color: Color) -> Double {
        var r, g, b, a: CGFloat
        (r, g, b, a) = (0, 0, 0, 0)
        UIColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
        let opacityFactor = colorScheme == .dark ? 0.33 * (1 - a) : 3 * (1 - a)
        return luminance * opacityFactor
    }
    
    var body: some View {
        card
            .foregroundColor(foregroundColor)
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                if !presetManager.open {
                    presetManager.open = true
                    return
                }
                Task {
                    presetManager.open = false
                    if !isActive {
                        try await presetManager.loadOverlay(preset: preset, secs: preset.overlayTimeSecs)
                    }
                }
            }
    }
}
