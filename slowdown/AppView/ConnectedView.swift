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
            HStack(alignment: .bottom) {
                text
                    .font(.headline.bold())
                Spacer()
            }
            .padding(.bottom, 20)
        }
    }
}

struct PresetCardStackModifier: ViewModifier {
    @EnvironmentObject var presetManager: PresetManager
    let index: Int
    let originalIndex: Int
    let total: Int
    let active: Bool
    
    var openHeight: Double {
        return (UIScreen.main.bounds.height - 60) / Double(total)
    }
    
    var y: Double {
        if presetManager.state == .open {
            return Double(total - originalIndex - 1) * -openHeight
        }
        return Double(total - index - 2) *  18
    }
    
    var height: Double {
        if presetManager.state == .closed {
            if active {
                return UIScreen.main.bounds.height - 100.0
            }
        }
        return 250
    }
    
    func body(content: Content) -> some View {
        content
            .frame(height: height)
            .offset(
                x: 0,
                y: y
            )
            .animation(
                .spring(response: 0.50, dampingFraction: 0.825, blendDuration: 0),
                value: y
            )
            .animation(
                .spring(response:  0.50, dampingFraction: 0.825, blendDuration: 0),
                value: height
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
        ZStack(alignment: .bottom) {
            WiredPauseCard()
                .modifier(PresetCardStackModifier(index: 0, originalIndex: 0, total: cardCount, active: false))
            ForEach(presets, id:\.id) { preset in
                preset.makeCard()
                    .modifier(PresetCardStackModifier(
                        index: map[preset.id]!.0,
                        originalIndex: map[preset.id]!.1,
                        total: cardCount,
                        active: settingsStore.settings.activePreset.id == preset.id
                    ))
                    .id(preset.id)
            }
        }
//        .frame(maxHeight: UIScreen.main.bounds.height)
//        .background(.ultraThinMaterial.opacity(presetManager.open ? 1 : 0))
//        .animation(.easeInOut(duration: presetManager.open ? 0.5 : 2), value: presetManager.open)
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
