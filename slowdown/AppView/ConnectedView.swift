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
            SlowingStatus()
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
    
    var healTimeLeft: Int {
        return Int(stateController.healTimeLeft)
    }
    
    var scrollTimeLeft: Int {
        return Int(stateController.scrollTimeLeft)
    }
    
    @ViewBuilder
    var timeLeftCaption: some View {
        if scrollTimeLeft == 0 {
            Text("\(healTimeLeft) minute\(healTimeLeft != 1 ? "s" : "") until healed")
                .font(.caption)
        } else {
            Text("\(scrollTimeLeft) minute\(scrollTimeLeft != 1 ? "s" : "") of scrolling left")
                .font(.caption)
        }
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                text
                    .font(.headline.bold())
                Spacer()
                timeLeftCaption
            }
            .padding(.bottom, 20)
            WiredStagedDamageBar(height: 20)
            .padding(.bottom, 20)
        }
        .padding()
    }
}

struct PauseCard: View {
    var body: some View {
        Card(
            title: "Pause",
            caption: "Disconnects from VPN for 1 hour",
            backgroundColor: Color.gray
        ) {
            
        }
    }
}

struct WiredPauseCard: View {
    @EnvironmentObject var vpnLifecycleManager: VPNLifecycleManager
    @EnvironmentObject var presetManager: PresetManager
    var body: some View {
        PauseCard()
            .onTapGesture {
                if !presetManager.open {
                    presetManager.open = true
                    return
                }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                vpnLifecycleManager.pauseConnection()
            }
    }
}

struct WiredPresetCard: View {
    @EnvironmentObject var vpnLifecycleManager: VPNLifecycleManager
    @EnvironmentObject var presetManager: PresetManager
    @EnvironmentObject var settingsStore: SettingsStore
    
    var preset: Proxyservice_Preset
    
    var body: some View {
        ProgressiveCard(
            model: PresetViewModel(
                preset: Binding(
                    get: {
                        return preset
                    },
                    set: { _ in }
                )
            )) {
                
            }
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                if !presetManager.open {
                    presetManager.open = true
                    return
                }
                if preset.id != settingsStore.settings.activePreset.id {
                    presetManager.loadPreset(preset: preset)
                }
                presetManager.open = false
            }
        
    }
}

protocol Cardable {
    associatedtype V: View
    @ViewBuilder
    func makeCard() -> V
}

extension Proxyservice_Preset: Cardable {
    func makeCard() -> some View {
        WiredPresetCard(preset: self)
    }
}

struct PresetCardStackModifier: ViewModifier {
    @EnvironmentObject var presetManager: PresetManager
    let index: Int
    let total: Int
    
    var openHeight: Double {
        return (UIScreen.main.bounds.height - 60) / Double(total)
    }
    
    func body(content: Content) -> some View {
        content
            .offset(
                x: 0,
                y: [
                    Double(total - index - 1) * (presetManager.open ? -openHeight: -10),
                ].reduce(0, { acc, next in acc + next})
            )
            .animation(
                .spring(),
                value: "\(presetManager.open) \(index)"
            )
            .zIndex(index == total - 1 ? 1 : 0)
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
    
    func getCardIndexMap() -> Dictionary<String, Int> {
        var afterActive = false
        var map =  Dictionary<String, Int>()
        for i in presets.indices {
            let preset = presets[i]
            if preset.id == settingsStore.activePreset.id {
                map[preset.id] = cardCount - 1
                afterActive = true
            } else {
                map[preset.id] = i + 1 + (afterActive ? -1 : 0)
            }
        }
        return map
    }
    
    var body: some View {
        let map = getCardIndexMap()
        ZStack(alignment: .bottom) {
            WiredPauseCard()
                .modifier(PresetCardStackModifier(index: 0, total: cardCount))
            ForEach(presets, id:\.id) { preset in
                preset.makeCard()
                    .modifier(PresetCardStackModifier(index: map[preset.id]!, total: cardCount))
            }
        }
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
