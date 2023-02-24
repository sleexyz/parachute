//
//  ConnectedView.swift
//  slowdown
//
//  Created by Sean Lee on 2/15/23.
//

import Foundation
import SwiftUI
import ProxyService

struct ConnectedView: View {
    @EnvironmentObject var vpnLifecycleManager: VPNLifecycleManager
    @EnvironmentObject var service: VPNConfigurationService
    @EnvironmentObject var stateController: StateController
    var body: some View {
        VStack {
            Spacer()
            CardSelector()
        }
    }
}

struct SlowingStatus: View {
    @EnvironmentObject var stateController: StateController
    @Environment(\.colorScheme) var colorScheme

    
    @State var appeared: Bool = false
    
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
                    .font(.headline.bold())
                Spacer()
            }
            .padding(.bottom, 20)
            WiredStagedDamageBar(height: 20)
        }
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.default) {
                appeared = true
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
    
    var closedHeight: Double {
        return containerHeight / Double(total)
    }
    
    var stackHeight: Double {
        20
    }
    
    var y: Double {
        // any card opened
        if presetManager.state != .cardClosed {
            var ret: Double = 0
            ret += Double(total - index - 1) * stackHeight
            ret -= extraStackGap
            return ret
        // card closed
        } else {
            return -Double(total - selectorOpenIndex - 1) * closedHeight
        }
    }
    
    var height: Double {
        // actual card opened / opening
        if presetManager.state == .cardOpened && active {
            return containerHeight - extraStackGap
        // card closed
        } else {
            return closedHeight
        }
    }
    
    var extraStackGap: Double {
        let numAdditionalCards = Double(total - 1)
        return stackHeight * numAdditionalCards
    }
    
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(height: height)
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
            .zIndex(active ? 1 : 0)
    }
}

struct CardSelector: View {
    @EnvironmentObject var presetManager: PresetManager
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var stateController: StateController
    @EnvironmentObject var vpnLifecycleManager: VPNLifecycleManager
    
    var presets: Array<Proxyservice_Preset> {
        return PresetManager.defaultPresets
    }
    
    var cardCount: Int {
        return presets.count + 1
    }
    
    func getCardIndexMap() -> Dictionary<String, (Int, Int)> {
        var afterActive = false
        var map =  Dictionary<String, (Int, Int)>()
        for i in presets.indices {
            let preset = presets[i]
            if preset.id == settingsStore.activePreset.id {
                map[preset.id] = (cardCount - 1, i + 1)
                afterActive = true
            } else {
                map[preset.id] = (i + 1 + (afterActive ? -1 : 0), i + 1)
            }
        }
        return map
    }
    
    var body: some View {
        let map = getCardIndexMap()
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
            ForEach(presets, id:\.id) { preset in
                preset.makeCard()
                    .modifier(CardPositionerModifier(
                        index: map[preset.id]!.0,
                        selectorOpenIndex: map[preset.id]!.1,
                        total: cardCount,
                        active: settingsStore.settings.activePreset.id == preset.id,
                        containerHeight: containerHeight
                    ))
            }
        }
        .frame(height: realContainerHeight)
//        .background(.ultraThinMaterial.opacity(presetManager.state == .cardOpened ? 0 : 1))
//        .animation(.easeInOut(duration: 1), value: presetManager.state == .cardOpened)
        .onTapBackground(enabled: presetManager.open) {
            presetManager.open = false
        }
    }
}

struct ConnectedView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectedView()
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
