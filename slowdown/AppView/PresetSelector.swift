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
    
    @Environment(\.activeStackPosition) var activeStackPosition: StackPosition
    @Environment(\.closedStackPosition) var closedStackPosition: StackPosition
    
    var cardHeight: Double {
        return containerHeight / Double(total)
    }
    
    var stackSpacing: Double {
        20
    }
    
    func getStackY(stackPos: StackPosition) -> Double {
        switch(stackPos) {
        case .top:
            return -containerHeight + cardHeight
        case .bottom:
            return -extraStackGap - stackSpacing * Double(total - stackLength)
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
        if profileManager.state != .cardClosed {
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
        if profileManager.state != .cardClosed {
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
                profileManager.state.animation,
                value: y
            )
            .animation(
                profileManager.state.animation,
                value: height
            )
            .animation(
                profileManager.state.animation,
                value: profileManager.state == .cardOpened
            )
            .zIndex(zIndex)
    }
}

struct PresetSelector: View {
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var stateController: StateController
    @EnvironmentObject var vpnLifecycleManager: VPNLifecycleManager
    
    var shouldRender: Bool
    
    var presets: OrderedDictionary<String, Preset> {
        var map = OrderedDictionary<String, Preset>()
        for presetID in profileManager.activeProfile.presets {
            map[presetID] = Preset.presets[presetID]
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
        if profileManager.state == .cardOpened {
            return fullContainerHeight
        }
        return fullContainerHeight * 0.75
    }
    
    var containerHeight: Double {
        return fullContainerHeight * 0.65
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
                        containerHeight: containerHeight
                    )
        }
        return map
    }
    var background: some ShapeStyle {
        profileManager.activeProfile.color.opacity(profileManager.state == .cardOpened ? 0 : 1)
    }
    
    var material: some ShapeStyle {
        Material.ultraThinMaterial.opacity(profileManager.state == .cardOpened ? 0 : 1)
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
                if profileManager.state == .cardOpened {
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
                            preset.makeCard()
                                .transition(AnyTransition.asymmetric(
                                    insertion: .opacity.animation(profileManager.state.animation.delay(ANIMATION_SECS * delay(preset: preset))),
                                    removal: .opacity.animation(profileManager.state.animation)
                                ))
                                .modifier(modifiers[preset.id]!)
                        }
                    }
                    if shouldRender {
                        WiredPauseCard()
                                .transition(AnyTransition.asymmetric(
                                    insertion: .opacity.animation(profileManager.state.animation.delay(ANIMATION_SECS * 2)),
                                    removal: .opacity.animation(profileManager.state.animation)
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
//            .padding(.top, profileManager.state != .cardOpened ? 180 : 0)
            .frame(height: fullContainerHeight, alignment: .center)
            .background(material)
//            if profileManager.state != .cardOpened {
//                VStack {
//                    if !profileManager.profileSelectorOpen {
//                        ProfileButton(profile: profileManager.activeProfile, profileID: settingsStore.settings.profileID)
//                            .padding(80)
//                            .transition(AnyTransition.asymmetric(
//                                insertion: .opacity.animation(profileManager.state.animation),
//                                removal: .opacity.animation(.easeInOut(duration: 0.1))
//                            ))
//                    }
//                }
//                .frame(maxHeight: .infinity, alignment: .bottom)
//                .transition(AnyTransition.asymmetric(
//                    insertion: .opacity.animation(profileManager.state.animation.delay(0.3)),
//                    removal: .opacity.animation(.easeInOut(duration: 0.1))
//                ))
//            }
        }
        .animation(profileManager.state.animation, value: profileManager.state == .cardOpened)
        .animation(profileManager.state.animation, value: profileManager.profileSelectorOpen)
    }
}
