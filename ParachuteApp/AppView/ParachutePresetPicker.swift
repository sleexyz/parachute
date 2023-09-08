//
//  ParachutePresetPicker.swift
//  slowdown
//
//  Created by Sean Lee on 3/20/23.
//

import Controllers
import Foundation
import Models
import ProxyService
import SwiftUI

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
        profileManager.activePreset.mainColor
            .opacity(active ? 1 : 0)
    }

    var computedBackgroundColor: Color {
        var color: Color
        if colorScheme == .dark {
            color = background.deepenByAlphaAndBake()
        }
        color = background.bakeAlpha(colorScheme)
        return color
    }

    var foregroundColor: Color {
        computedBackgroundColor.bakeAlpha(colorScheme).getForegroundColor()
    }

    var body: some View {
        return Text("\(Int(hp)) min")
            .padding()
//            .frame(maxWidth: .infinity)
            .background(computedBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: CARD_PADDING, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: CARD_PADDING, style: .continuous)
                .stroke(.ultraThinMaterial)
            )
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
            Spacer()
            ParachutePresetItem(hp: 10)
            Spacer()
            ParachutePresetItem(hp: 5)
            Spacer()
            ParachutePresetItem(hp: 2)
            Spacer()
        }
    }
}
