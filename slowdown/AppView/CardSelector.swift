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
    @EnvironmentObject var presetManager: PresetManager
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
            return extraStackGap  / 2 - stackSpacing * 3
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
        if presetManager.state != .cardClosed {
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
        if presetManager.state != .cardClosed {
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
                presetManager.state.animation,
                value: y
            )
            .animation(
                presetManager.state.animation,
                value: height
            )
            .animation(
                presetManager.state.animation,
                value: presetManager.state == .cardOpened
            )
            .zIndex(zIndex)
    }
}

struct CardSelector: View {
    @EnvironmentObject var presetManager: PresetManager
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var stateController: StateController
    @EnvironmentObject var vpnLifecycleManager: VPNLifecycleManager
    
    var presets: OrderedDictionary<String, Preset> {
        return PresetManager.defaultProfile
    }
    
    var cardCount: Int {
        return presets.count + 1
    }
    
    var realContainerHeight: Double {
        UIScreen.main.bounds.height
    }
    
    var containerHeight: Double {
        realContainerHeight * 0.8
    }
    
    func getStackData() -> StackData {
        var selectorOpenSet = OrderedSet<String>()
        var activeSet =  OrderedSet<String>()
        var closedSet =  OrderedSet<String>()
        
        activeSet.append(settingsStore.defaultPreset.id)
        if let overlayId = settingsStore.activeOverlayPreset?.id {
            activeSet.append(overlayId)
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
    
    var body: some View {
        let modifiers = getCardPositionerModifiers()
        VStack {
            if presetManager.state != .cardOpened {
                Spacer().frame(height: 30)
            }
            ZStack(alignment: .bottom) {
                // Need rectangle to fill the full height
                Rectangle()
                    .opacity(0)
                    .frame(height: containerHeight)
                ForEach(presets.elements, id: \.key) { entry in
                    let preset = entry.value
                    preset.makeCard()
                        .modifier(modifiers[preset.id]!)
                }
                WiredPauseCard().modifier(modifiers[Pause().id]!)
            }
            if presetManager.state != .cardOpened {
                Spacer()
            }
        }
        .frame(height: realContainerHeight, alignment: presetManager.state == .cardOpened ? .bottom : .top)
        .onTapBackground(enabled: presetManager.open) {
            presetManager.open = false
        }
//        .background(.pink)
        .background(.ultraThinMaterial.opacity(presetManager.state == .cardOpened ? 0 : 1))
        .animation(presetManager.state.animation, value: presetManager.state == .cardOpened)
    }
}

