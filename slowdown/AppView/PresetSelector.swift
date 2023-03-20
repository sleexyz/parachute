//
//  PresetSelector.swift
//  slowdown
//
//  Created by Sean Lee on 3/20/23.
//

import Foundation
import OrderedCollections
import SwiftUI

struct PresetSelector: View {
    @EnvironmentObject var profileManager: ProfileManager
    
    var shouldRender: Bool
    
    var cards: OrderedDictionary<String, AnyCardable> {
        var map = OrderedDictionary<String, AnyCardable>()
        for presetID in profileManager.activeProfile.presets {
            map[presetID] = Preset.presets[presetID]?.eraseToAnyCardable()
        }
        map[Pause().id] = Pause().eraseToAnyCardable()
        return map
    }
    
    func delay(preset: Preset) -> Double {
        if profileManager.activePreset.id == preset.id {
            return 2
        }
        return 2
    }
    
    func insertionTransition(cardable: AnyCardable) -> AnyTransition {
        if cardable.id == profileManager.activePreset.id {
            return .identity
        }
        return .opacity.animation(ANIMATION.delay(ANIMATION_SECS * 1.5))
    }
    
    var material: some ShapeStyle {
        Material.ultraThickMaterial.opacity(profileManager.presetSelectorOpen ? 1 : 0)
    }
    
    var height: Double {
        return UIScreen.main.bounds.height * 0.9
    }
    
    var body: some View {
        VStack {
            Spacer()
            ForEach(cards.elements.reversed(), id: \.key) { entry in
                if shouldRender{
                    entry.value.makeCard()
                        .padding()
                        .transition(AnyTransition.asymmetric(
                            insertion: insertionTransition(cardable: entry.value),
                            removal: .opacity.animation(ANIMATION)
                        ))
                }
                
            }
            if shouldRender {
                VStack {
                    if !profileManager.profileSelectorOpen {
                        ProfileButton(profile: profileManager.activeProfile)
                            .transition(AnyTransition.asymmetric(
                                insertion: .opacity.animation(ANIMATION),
                                removal: .opacity.animation(.easeInOut(duration: 0.1))
                            ))
                    }
                }
                .frame(height: UIScreen.main.bounds.height / 8, alignment: .center)
                .transition(AnyTransition.asymmetric(
                    insertion: .opacity.animation(ANIMATION.delay(ANIMATION_SECS*2.5)),
                    removal: .opacity.animation(ANIMATION_SHORT)
                ))
            }
        }
        .onTapBackground(enabled: profileManager.presetSelectorOpen) {
            profileManager.presetSelectorOpen = false
        }
        .frame(maxWidth: .infinity, minHeight: height)
        .background(material)
        .animation(ANIMATION, value: profileManager.presetSelectorOpen)
    }
}

struct SelectedPreset: View {
    @EnvironmentObject var profileManager: ProfileManager
    var shouldRender: Bool
    
    var body: some View {
        if shouldRender {
            profileManager.activePreset.makeCard()
                .padding()
        }
    }
}
