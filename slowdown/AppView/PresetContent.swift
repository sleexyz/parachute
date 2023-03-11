//
//  PresetContent.swift
//  slowdown
//
//  Created by Sean Lee on 3/10/23.
//

import Foundation
import SwiftUI

struct PresetContent: View {
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var presetManager: ProfileManager
    
    var model: PresetViewModel {
        PresetViewModel(presetData: settingsStore.activePresetBinding, preset: presetManager.activePreset)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            if settingsStore.activePreset.mode == .progressive {
                VStack {
                    ProfileHeader()
                    PresetHeader()
                    SlowingStatus()
                        .padding()
                    Spacer()
                }
            } else {
                VStack {
                    ProfileHeader()
                    PresetHeader()
                    Spacer()
                }
                
            }
        }
                .padding(.top, TOP_PADDING)
                .padding(CARD_PADDING)
    }
}

struct ProfileHeader: View {
    @EnvironmentObject var profileManager: ProfileManager
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Text(profileManager.activeProfile.icon)
                    .font(.largeTitle)
                Text(profileManager.activeProfile.name)
                    .font(.title)
            }
                .frame(maxWidth: .infinity, alignment: .bottomLeading)
        }
            .padding(.top, 20)
            .padding(.bottom, 20)
    }
    
}

//struct Background: View {
//    var model: PresetViewModel
//    @EnvironmentObject var settingsStore: SettingsStore
//    @EnvironmentObject var presetManager: ProfileManager
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
//                .animation(presetManager.state.animation, value: model.mainColor)
//    }
//}


struct PresetHeader: View {
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var presetManager: ProfileManager
    var body: some View {
        HStack {
            Text(presetManager.activePreset.name)
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
            WiredStagedDamageBar(height: 20)
                .padding(.bottom, 20)
            HStack(alignment: .bottom) {
                text
                    .font(.headline)
                    .opacity(0.4)
                Spacer()
            }
        }
        
    }
}
