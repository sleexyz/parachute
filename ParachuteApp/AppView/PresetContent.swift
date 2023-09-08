//
//  PresetContent.swift
//  slowdown
//
//  Created by Sean Lee on 3/10/23.
//

import Controllers
import Foundation
import SwiftUI

let TOP_PADDING: Double = 40

struct PresetContent: View {
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var profileManager: ProfileManager

    var model: PresetViewModel {
        PresetViewModel(presetData: settingsStore.activePresetBinding, preset: profileManager.activePreset)
    }

    var body: some View {
        VStack {
//            PresetHeader()
            if settingsStore.activePreset.mode == .progressive {
                SlowingStatus()
                    .padding()
            }
            Spacer()
        }
        .padding(CARD_PADDING)
    }
}

// struct Background: View {
//    var model: PresetViewModel
//    @EnvironmentObject var settingsStore: SettingsStore
//    @EnvironmentObject var profileManager: ProfileManager
//
//    var body: some View {
//            Spacer()
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(
//                    LinearGradient(
//                        gradient: Gradient(
//                            colors: [
//                                Color.white,
//                                Color.clear,
//                            ]),
//                        startPoint: .top,
//                        endPoint: .bottom
//                    )
//                )
//                .colorMultiply(model.mainColor)
//                .animation(ANIMATION, value: model.mainColor)
//    }
// }

struct PresetHeader: View {
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var profileManager: ProfileManager
    var body: some View {
        HStack {
            Text(profileManager.activePreset.name)
                .font(.headline)
                .bold()
                .padding()
            Spacer()
        }
    }
}

struct SlowingStatus: View {
    @EnvironmentObject var stateController: StateController
    @Environment(\.colorScheme) var colorScheme

    @ViewBuilder
    var text: some View {
        if stateController.isSlowing {
            Text("Slowing down apps...")
        } else {
            Text("Slowing disabled")
        }
    }

    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                text
                    .font(.headline)
                    .opacity(0.4)
                Spacer()
            }
            .padding(.bottom, 20)
            WiredStagedDamageBar(height: 20)
        }
    }
}
