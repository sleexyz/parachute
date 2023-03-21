//
//  CardSelector.swift
//  slowdown
//
//  Created by Sean Lee on 2/19/23.
//

import Foundation
import SwiftUI
import OrderedCollections


enum StackPosition {
    case top // Entire card visible, top
    case bottom // Entire card visible, bottom
    case belowbelow // Card padding visible
}

struct StackData {
    var selectorOpenSet: OrderedSet<String>
    var activeSet: OrderedSet<String>
    var closedSet: OrderedSet<String>
}

enum StackType {
    case active
    case closed
}

private struct ActiveStackPositionKey: EnvironmentKey {
    static let defaultValue = StackPosition.top
}

private struct ClosedStackPositionKey: EnvironmentKey {
    static let defaultValue = StackPosition.bottom
}

extension EnvironmentValues {
    var activeStackPosition: StackPosition {
        get { self[ActiveStackPositionKey.self] }
        set { self[ActiveStackPositionKey.self] = newValue }
    }
    
    var closedStackPosition: StackPosition {
        get { self[ClosedStackPositionKey.self] }
        set { self[ClosedStackPositionKey.self] = newValue }
    }
}

struct CardPositionerModifier: ViewModifier {
    @EnvironmentObject var profileManager: ProfileManager
    let selectorOpenIndex: Int
    let index: Int
    let stack: StackType
    let stackLength: Int
    let total: Int
    let containerHeight: Double
    let cardHeight: Double
    
    @Environment(\.activeStackPosition) var activeStackPosition: StackPosition
    @Environment(\.closedStackPosition) var closedStackPosition: StackPosition
    
    
    var stackSpacing: Double {
        20
    }
    
    func getStackY(stackPos: StackPosition) -> Double {
        switch(stackPos) {
        case .top:
            return -containerHeight + cardHeight
        case .bottom:
            return -extraStackGap - stackSpacing * Double(total - stackLength + 1)
        case .belowbelow:
            return cardHeight - (stackSpacing * Double(stackLength + 1))
        }
    }
    
    func getOffsetY(stackPos: StackPosition) -> Double {
        switch(stackPos) {
        case .top:
            return Double(stackLength - index - 1) * stackSpacing
        case .bottom:
            return Double(stackLength - index - 1) * stackSpacing
        case .belowbelow:
            return Double(index) * stackSpacing
        }
    }
    
    var stackY: Double {
        if !profileManager.presetSelectorOpen {
            if stack == .active {
                return getStackY(stackPos: activeStackPosition)
            } else {
                return getStackY(stackPos: closedStackPosition)
            }
        }
        return 0
    }
    
    var y: Double {
        stackY + offsetY
    }
    
    var offsetY: Double {
        // any card opened
        if !profileManager.presetSelectorOpen {
            if stack == .active {
                return getOffsetY(stackPos: activeStackPosition)
            } else {
                return getOffsetY(stackPos: closedStackPosition)
            }
        }
        // card closed
        return -Double(selectorOpenIndex) * cardHeight
    }
    
    var height: Double {
        return cardHeight
    }
    
    var extraStackGap: Double {
        return Double(stackLength - 1) * stackSpacing
    }
    
    var zIndex: Double {
        var value = Double(index) / Double(total)
        if stack == .active {
            value += 1
        }
        return value
    }
    
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(height: height, alignment: .topLeading)
            .offset(x: 0, y: y)
            .animation(
                ANIMATION,
                value: y
            )
            .animation(
                ANIMATION,
                value: height
            )
            .animation(
                ANIMATION,
                value: !profileManager.presetSelectorOpen
            )
            .zIndex(zIndex)
    }
}

struct PresetSelectorOld: View {
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var stateController: StateController
    @EnvironmentObject var vpnLifecycleManager: VPNLifecycleManager
    
    var shouldRender: Bool
    
    var presets: OrderedDictionary<String, Preset> {
        var map = OrderedDictionary<String, Preset>()
        for presetID in profileManager.activeProfile.presets {
            map[presetID] = profileManager.allPresets[presetID]
        }
        return map
    }
    
    var cardCount: Int {
        return presets.count + 1
    }
    
    var fullContainerHeight: Double {
        return UIScreen.main.bounds.height
    }
    
    var profileContainerHeight: Double {
        if !profileManager.presetSelectorOpen {
            return fullContainerHeight
        }
        return fullContainerHeight * 0.75
    }
    
    var containerHeight: Double {
        return fullContainerHeight * 0.8
    }
    
    var cardHeight: Double {
        return containerHeight / Double(max(cardCount, 4))
    }

    
    
    func getStackData() -> StackData {
        var selectorOpenSet = OrderedSet<String>()
        var activeSet =  OrderedSet<String>()
        var closedSet =  OrderedSet<String>()
        
        if let overlayId = settingsStore.activeOverlayPreset?.id {
            activeSet.append(overlayId)
        } else {
            activeSet.append(settingsStore.defaultPreset.id)
        }
        
        for entry in presets {
            let id = entry.value.id
            selectorOpenSet.append(id)
            if !activeSet.contains(id) {
                closedSet.append(id)
            }
        }
        selectorOpenSet.append(Pause().id)
        closedSet.append(Pause().id)
        return StackData(selectorOpenSet: selectorOpenSet, activeSet: activeSet, closedSet: closedSet)
    }
    
    func getCardPositionerModifiers() -> Dictionary<String, CardPositionerModifier> {
        let stackData = getStackData()
        var map = Dictionary<String, CardPositionerModifier>()
        var ids = presets.keys
        ids.append(Pause().id)
        
        for id in ids {
            var index = 0
            var stack: StackType = .active
            var stackLength: Int = 0
            if let activeIndex = stackData.activeSet.firstIndex(of: id) {
                index = activeIndex
                stack = .active
                stackLength = stackData.activeSet.count
            }
            if let closedIndex = stackData.closedSet.firstIndex(of: id) {
                index = closedIndex
                stack = .closed
                stackLength = stackData.closedSet.count
            }
            map[id] = CardPositionerModifier(
                        selectorOpenIndex: stackData.selectorOpenSet.firstIndex(of: id)!,
                        index: index,
                        stack: stack,
                        stackLength: stackLength,
                        total: cardCount,
                        containerHeight: containerHeight,
                        cardHeight: cardHeight
                    )
        }
        return map
    }
    var background: some ShapeStyle {
        profileManager.activeProfile.color.opacity(profileManager.presetSelectorOpen ? 1 : 0)
    }
    
    var material: some ShapeStyle {
        Material.ultraThinMaterial.opacity(profileManager.presetSelectorOpen ? 1 : 0)
    }
    
    @Environment(\.namespace) var namespace: Namespace.ID
    @Namespace var namespaceOverride: Namespace.ID
    
    func delay(preset: Preset) -> Double {
        if profileManager.activePreset.id == preset.id {
            return 2
        }
        return 2
    }
    
    var body: some View {
        let modifiers = getCardPositionerModifiers()
        ZStack(alignment: .top) {
            VStack {
                if !profileManager.presetSelectorOpen {
                    Spacer()
                }
                ZStack(alignment: .bottom) {
                    // Need rectangle to fill the full height
                    Rectangle()
                        .opacity(0)
                        .frame(height: containerHeight)
                    ForEach(presets.elements, id: \.key) { entry in
                        let preset = entry.value
                        if shouldRender {
                            preset.makeCard() {
                                AnyView(EmptyView())
                            }
                                .transition(AnyTransition.asymmetric(
                                    insertion: .opacity.animation(ANIMATION.delay(ANIMATION_SECS * delay(preset: preset))),
                                    removal: .opacity.animation(ANIMATION)
                                ))
                                .modifier(modifiers[preset.id]!)
                        }
                    }
                    if shouldRender {
                        WiredPauseCard(id: Pause().id) {
                            AnyView(EmptyView())
                        }
                                .transition(AnyTransition.asymmetric(
                                    insertion: .opacity.animation(ANIMATION.delay(ANIMATION_SECS * 2)),
                                    removal: .opacity.animation(ANIMATION)
                                ))
                            .modifier(modifiers[Pause().id]!)
                    }
                }
            }
            .onTapBackground(enabled: profileManager.presetSelectorOpen) {
                withAnimation {
                    profileManager.presetSelectorOpen = false
                }
            }
            .padding(.bottom, profileManager.presetSelectorOpen ? 120: 0)
            .frame(height: fullContainerHeight, alignment: .center)
            .background(material)
            if profileManager.presetSelectorOpen {
                VStack {
                    if !profileManager.profileSelectorOpen {
                        ProfileButton(profile: profileManager.activeProfile)
                            .padding(80)
                            .transition(AnyTransition.asymmetric(
                                insertion: .opacity.animation(ANIMATION),
                                removal: .opacity.animation(.easeInOut(duration: 0.1))
                            ))
                    }
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                .transition(AnyTransition.asymmetric(
                    insertion: .opacity.animation(ANIMATION.delay(ANIMATION_SECS*2.5)),
                    removal: .opacity.animation(.easeInOut(duration: 0.1))
                ))
            }
        }
        .animation(ANIMATION, value: profileManager.presetSelectorOpen)
        .animation(ANIMATION, value: profileManager.profileSelectorOpen)
    }
}
