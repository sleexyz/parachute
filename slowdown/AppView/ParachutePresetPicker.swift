//
//  ParachutePresetPicker.swift
//  slowdown
//
//  Created by Sean Lee on 3/20/23.
//

import Foundation
import SwiftUI
import ProxyService

struct ParachutePresetItem: View {
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var stateController: StateController
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    var hp: Double
    
    var active: Bool {
        settingsStore.activePreset.usageMaxHp == hp
    }
    
    var preset: Preset {
        ProfileManager.makeParachutePreset(ProfileManager.makeParachutePresetData(hp: hp))
    }
    
    var background: Color {
        profileManager.activePreset.mainColor.opacity(active ? 1 : 0)
    }
    var computedBackgroundColor: Color {
        if colorScheme == .dark {
            return background.deepenByAlphaAndBake()
        }
        return background.bakeAlpha(colorScheme)
    }
    
    var foregroundColor: Color {
        computedBackgroundColor.getForegroundColor()
    }
    
    var body: some View {
        return Text("\(Int(hp)) min")
            .padding()
//            .frame(maxWidth: .infinity)
            .background(computedBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: CARD_PADDING, style: .continuous))
//            .overlay(RoundedRectangle(cornerRadius: CARD_PADDING, style: .continuous)
//                .stroke(.ultraThinMaterial)
//            )
            .padding(.top, 10)
            .padding(.bottom, 10)
            .foregroundColor(foregroundColor)
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                profileManager.loadParachutePreset(
                    preset: preset)
                if preset.presetData.mode == .progressive {
                    stateController.heal()
                }
                Task {
                    try await Task.sleep(nanoseconds: 400_000_000)
                    profileManager.presetSelectorOpen = false
                }
            }
    }
}

struct ParachutePresetPicker: View {
    var body: some View {
        VStack(spacing: 0) {
            ParachutePresetItem(hp: 10)
            ParachutePresetItem(hp: 5)
            ParachutePresetItem(hp: 2)
        }
    }
}
