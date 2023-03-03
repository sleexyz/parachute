//
//  ConnectedView.swift
//  slowdown
//
//  Created by Sean Lee on 2/15/23.
//

import Foundation
import SwiftUI
import ProxyService
import OrderedCollections

enum CardPosition {
    case top
    case bottom
    case below
    case belowbelow
}

private struct ActiveCardPositionKey: EnvironmentKey {
    static let defaultValue = CardPosition.top
}

private struct ClosedStackPositionKey: EnvironmentKey {
    static let defaultValue = CardPosition.bottom
}

extension EnvironmentValues {
    var activeCardPosition: CardPosition {
        get { self[ActiveCardPositionKey.self] }
        set { self[ActiveCardPositionKey.self] = newValue }
    }
    
    var closedStackPosition: CardPosition {
        get { self[ClosedStackPositionKey.self] }
        set { self[ClosedStackPositionKey.self] = newValue }
    }
}

var noExpand = true

struct Background: View {
    var model: PresetViewModel
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var presetManager: PresetManager
    
    var body: some View {
            Spacer()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(
                            colors: [
//                                Color.white,
                                Color.white.opacity(0),
                            ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .colorMultiply(model.mainColor)
                .animation(presetManager.state.animation, value: model.mainColor)
    }
}

struct PresetContent: View {
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var presetManager: PresetManager
    
    var model: PresetViewModel {
        PresetViewModel(presetData: settingsStore.activePresetBinding, preset: PresetManager.getPreset(id: settingsStore.activePreset.id))
    }
    
    var body: some View {
        ZStack {
            Background(model: model)
            ZStack {
                if settingsStore.activePreset.mode == .progressive {
                    VStack {
                        PresetHeader()
                        SlowingStatus()
                            .padding()
                        Spacer()
                    }
                    .padding(.top, 60)
                } else {
                    VStack {
                        PresetHeader()
                        Spacer()
                    }
                    .padding(.top, 60)
                    
                }
            }
//            .opacity(presetManager.state == .cardOpened ? 1 : 0)
//            .animation(.easeInOut, value: presetManager.state == .cardOpened)
        }
    }
}

struct PresetHeader: View {
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var presetManager: PresetManager
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

struct ConnectedView: View {
    @EnvironmentObject var vpnLifecycleManager: VPNLifecycleManager
    @EnvironmentObject var service: VPNConfigurationService
    @EnvironmentObject var stateController: StateController
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var presetManager: PresetManager
    
    var body: some View {
        ZStack {
            PresetContent()
            VStack {
                CardSelector()
                    .environment(\.closedStackPosition, .belowbelow)
                    .environment(\.activeCardPosition, .bottom)
                Spacer()
            }
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

struct CardPositionerModifier: ViewModifier {
    @EnvironmentObject var presetManager: PresetManager
    let index: Int
    let selectorOpenIndex: Int
    let total: Int
    let active: Bool
    let containerHeight: Double
    
    @Environment(\.activeCardPosition) var activeCardPosition: CardPosition
    @Environment(\.closedStackPosition) var closedStackPosition: CardPosition
    
    var closedHeight: Double {
        return containerHeight / Double(total)
    }
    
    var totalClosed: Int {
        if activeCardPosition != closedStackPosition {
            return total - 1
        }
        return total
    }
    
    var stackHeight: Double {
        10
    }
    
    var y: Double {
        // any card opened
        if presetManager.state != .cardClosed {
            if active {
                if activeCardPosition == .top {
                    return -containerHeight + closedHeight
                }
                if activeCardPosition == .bottom {
                    return Double(total - index - 1) * stackHeight - extraStackGap / 2
                }
                if activeCardPosition == .below {
                    return closedHeight - Double(total - index - 1) * stackHeight - 50
                }
                if activeCardPosition == .belowbelow {
                    return closedHeight - Double(total - index - 1) * stackHeight
                }
            }
            if closedStackPosition == .bottom {
                return Double(total - index - 1) * stackHeight - extraStackGap / 2
            }
            if closedStackPosition == .below {
                return closedHeight - Double(total - index - 1) * stackHeight - 50
            }
            if closedStackPosition == .belowbelow {
                return closedHeight - Double(totalClosed - index - 1) * stackHeight
            }
            return 0
        // card closed
        } else {
//            if active && activeCardPosition == .below {
//                return closedHeight - Double(total - index - 1) * stackHeight - 50
//            }
//            return -Double(total - index - 1) * closedHeight
            return -Double(total - index - 1) * closedHeight
        }
    }
    
    var height: Double {
        if noExpand {
            return closedHeight
        }
        // actual card opened / opening
        if presetManager.state == .cardOpened && active {
            return containerHeight - extraStackGap
        // card closed
        } else {
            return closedHeight
        }
    }
    
    var extraStackGap: Double {
        var numAdditionalCards = Double(totalClosed - 1)
        return stackHeight * numAdditionalCards
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
//            .zIndex(active ? 1 : 0)
            .zIndex(Double(index))
    }
}

struct CardSelector: View {
    @EnvironmentObject var presetManager: PresetManager
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var stateController: StateController
    @EnvironmentObject var vpnLifecycleManager: VPNLifecycleManager
    
    var presets: OrderedDictionary<String, Preset> {
        return PresetManager.defaultPresets
    }
    
    
    var cardCount: Int {
        return presets.count + 1
    }
    
    func getCardIndexMapActiveLast() -> Dictionary<String, (Int, Int)> {
        var afterActive = false
        var map =  Dictionary<String, (Int, Int)>()
        for (i, entry) in presets.enumerated() {
            let id = entry.key
            if id == settingsStore.activePresetBinding.id {
                map[id] = (cardCount - 1, i + 1)
                afterActive = true
            } else {
                map[id] = (i + 1 + (afterActive ? -1 : 0), i + 1)
            }
        }
        return map
    }
    
    func getCardIndexMapActiveFirst() -> Dictionary<String, (Int, Int)> {
        var afterActive = false
        var map =  Dictionary<String, (Int, Int)>()
        for (i, entry) in presets.enumerated() {
            let id = entry.key
            if id == settingsStore.activePresetBinding.id {
                map[id] = (0, i + 1)
                afterActive = true
            } else {
//                map[id] = (i + 2 , i + 1)
                map[id] = (i + 2 + (afterActive ? -1 : 0), i + 1)
            }
        }
        return map
    }
    
    var body: some View {
        let map = getCardIndexMapActiveLast()
        let realContainerHeight = UIScreen.main.bounds.height / 1
        let containerHeight = realContainerHeight * 0.9
        ZStack(alignment: .bottom) {
            // Need rectangle to fill the full height
            Rectangle()
                .opacity(0)
                .frame(height: containerHeight)
            WiredPauseCard()
                .modifier(CardPositionerModifier(
                    index: 0,
                    selectorOpenIndex: 0,
                    total: cardCount,
                    active: false,
                    containerHeight: containerHeight
                ))
            ForEach(presets.elements, id: \.key) { entry in
                let preset = entry.value
                preset.makeCard()
                    .modifier(CardPositionerModifier(
                        index: map[preset.presetData.id]!.0,
                        selectorOpenIndex: map[preset.presetData.id]!.1,
                        total: cardCount,
                        active: settingsStore.activePreset.id == preset.presetData.id,
                        containerHeight: containerHeight
                    ))
            }
        }
        .frame(height: realContainerHeight)
        .onTapBackground(enabled: presetManager.open) {
            presetManager.open = false
        }
//        .background(.pink)
        .background(.ultraThinMaterial.opacity(presetManager.state == .cardOpened ? 0 : 1))
        .animation(presetManager.state.animation, value: presetManager.state == .cardOpened)
    }
}

struct ConnectedViewBelow_Previews: PreviewProvider {
    static var previews: some View {
        ConnectedView()
            .environment(\.closedStackPosition, .below)
            .environment(\.activeCardPosition, .below)
            .provideDeps(connectedPreviewDeps)
    }
}

struct ConnectedViewDefaultExpanded_Previews: PreviewProvider {
    static var previews: some View {
        ConnectedView()
            .consumeDep(PresetManager.self) { value in
                value.open = true
            }
            .provideDeps(connectedPreviewDeps)
    }
}

struct ConnectedViewWallet_Previews: PreviewProvider {
    static var previews: some View {
        ConnectedView()
            .environment(\.closedStackPosition, .below)
            .environment(\.activeCardPosition, .top)
            .provideDeps(connectedPreviewDeps)
    }
}

struct ConnectedViewSlowing_Previews: PreviewProvider {
    static var previews: some View {
        ConnectedView()
            .consumeDep(StateController.self) { value in
                value.setState(value: Proxyservice_GetStateResponse.with {
                    $0.usagePoints = 12
                })
            }
            .provideDeps(connectedPreviewDeps)
    }
}
