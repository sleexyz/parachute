//
//  PresetSelector.swift
//  slowdown
//
//  Created by Sean Lee on 3/20/23.
//

import Controllers
import Foundation
import Models
import OrderedCollections
import SwiftUI

struct PresetSelector: View {
    @EnvironmentObject var profileManager: ProfileManager

    @Namespace var additionalPresetsStackID

    var shouldRenderSelector: Bool {
        profileManager.presetSelectorOpen
    }

    var cards: OrderedDictionary<String, AnyCardable> {
        var map = OrderedDictionary<String, AnyCardable>()
        for entry in profileManager.presets {
            map[entry.key] = entry.value.eraseToAnyCardable()
        }
        map[Pause().id] = Pause().eraseToAnyCardable()
        return map
    }

    var profileCards: [OrderedDictionary<PresetID, Preset>.Element] {
        profileManager.topLevelPresets.elements.filter { $0.value.id != profileManager.defaultPreset.id }
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
        return .opacity.animation(ANIMATION)
    }

    var material: some ShapeStyle {
        Material.ultraThickMaterial.opacity(profileManager.presetSelectorOpen ? 1 : 0)
    }

    var height: Double {
        UIScreen.main.bounds.height
    }

    var body: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                VStack {
                    ForEach(cards.elements.reversed(), id: \.key) { entry in
                        if shouldRenderSelector || isActive(entry.value) {
                            Spacer()
                            entry.value.makeCard { () -> AnyView in
                                AnyView(
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
                        SeeMorePresetsButton()
                            .onTapGesture {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                withAnimation {
                                    scrollViewProxy.scrollTo(additionalPresetsStackID, anchor: .bottom)
                                }
                            }
                            .opacity(profileManager.profileSelectorOpen ? 0 : 1)
                            .animation(ANIMATION, value: profileManager.profileSelectorOpen)
                            .frame(height: 80)
                            .transition(AnyTransition.asymmetric(
                                insertion: .opacity.animation(ANIMATION.delay(ANIMATION_SECS * 2)),
                                removal: .opacity.animation(ANIMATION)
                            ))
                    }
                }
                .padding(.top, 40)
                .padding(.bottom, 40)
                .onTapBackground(enabled: profileManager.presetSelectorOpen) {
                    profileManager.presetSelectorOpen = false
                    profileManager.profileSelectorOpen = false
                }
                .frame(maxWidth: .infinity, minHeight: height, alignment: .bottom)
                if shouldRenderSelector {
                    VStack {
                        ForEach(profileCards, id: \.key) { entry in
                            entry.value.makeCard { () -> AnyView in
                                AnyView(EmptyView())
                            }
                            .padding()
                            .transition(AnyTransition.asymmetric(
                                insertion: insertionTransition(cardable: AnyCardable(cardable: entry.value)),
                                removal: .opacity.animation(ANIMATION)
                            ))
                        }
                    }
                    .padding(.top, -40)
                    .padding(.bottom, 40)
                    .id(additionalPresetsStackID)
                    .transition(AnyTransition.asymmetric(
                        insertion: .opacity.animation(ANIMATION.delay(ANIMATION_SECS * 2)),
                        removal: .opacity.animation(ANIMATION)
                    ))
                }
            }
            .frame(maxWidth: .infinity, minHeight: height, alignment: .bottom)
            .background(material)
            .animation(ANIMATION, value: shouldRenderSelector)
        }
    }
}

struct SeeMorePresetsButton: View {
    var body: some View {
        Divider()
            .padding()
            .opacity(0.5)
    }
}
