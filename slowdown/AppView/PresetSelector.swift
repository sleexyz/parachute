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
    
    var shouldRenderSelector: Bool {
        return profileManager.presetSelectorOpen
    }
    
    var cards: OrderedDictionary<String, AnyCardable> {
        var map = OrderedDictionary<String, AnyCardable>()
        for presetID in profileManager.activeProfile.presets {
            map[presetID] = profileManager.allPresets[presetID]?.eraseToAnyCardable()
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
    
    func isActive(_ cardable: AnyCardable) -> Bool {
        if cardable.id == profileManager.activePreset.id {
            return true
        }
        return false
    }
    func insertionTransition(cardable: AnyCardable) -> AnyTransition {
        if isActive(cardable) {
            return .identity
        }
        return .opacity.animation(ANIMATION.delay(ANIMATION_SECS * 1.5))
    }
    
    var material: some ShapeStyle {
        Material.ultraThickMaterial.opacity(profileManager.presetSelectorOpen ? 1 : 0)
    }
    
    var height: Double {
        return UIScreen.main.bounds.height
    }
    
    var body: some View {
        VStack {
            ForEach(cards.elements.reversed(), id: \.key) { entry in
                if shouldRenderSelector || isActive(entry.value) {
                    entry.value.makeCard { () ->  AnyView in
                        return AnyView(
                            entry.value.getExpandedBody()
                            .opacity(shouldRenderSelector ? 1 : 0)
                        )
                    }
                        .padding()
                        .environment(\.cardExpanded, shouldRenderSelector && isActive(entry.value))
                        .environment(\.captionShown, true)
                        .transition(AnyTransition.asymmetric(
                            insertion: insertionTransition(cardable: entry.value),
                            removal: .opacity.animation(ANIMATION)
                        ))
                }
                
            }
            if shouldRenderSelector {
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
        .padding(.top, 140)
        .padding(.bottom, 40)
        .onTapBackground(enabled: profileManager.presetSelectorOpen) {
            profileManager.presetSelectorOpen = false
        }
        .frame(maxWidth: .infinity, minHeight: height, alignment: .bottom)
        .background(material)
        .animation(ANIMATION, value: shouldRenderSelector)
    }
}
