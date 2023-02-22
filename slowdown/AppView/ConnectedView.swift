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
        ZStack(alignment: .center) {
            SlowingStatus()
//                .offset(x: 0, y: 280)
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
            HStack(alignment: .bottom) {
                text
                    .font(.headline.bold())
                Spacer()
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
    let originalIndex: Int
    let total: Int
    
    var openHeight: Double {
        return (UIScreen.main.bounds.height - 60) / Double(total)
    }
    
    var posY: Double {
        if !presetManager.open && index == total - 1 {
            return 125
        }
        if presetManager.open {
            return UIScreen.main.bounds.height - 150.0
        }
        return UIScreen.main.bounds.height + 75.0
    }
    
    var y: Double {
        if presetManager.open {
            return Double(total - originalIndex - 1) * -openHeight
        }
        return Double(total - index - 2) *  -25
    }
    
    func body(content: Content) -> some View {
        content
            .position(x: UIScreen.main.bounds.width / 2, y: posY)
            .offset(
                x: 0,
                y: y
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
                .modifier(PresetCardStackModifier(index: 0, originalIndex: 0, total: cardCount))
            ForEach(presets, id:\.id) { preset in
                preset.makeCard()
                    .modifier(PresetCardStackModifier(
                        index: map[preset.id]!.0,
                        originalIndex: map[preset.id]!.1,
                        total: cardCount
                    ))
            }
        }
        .background(.ultraThinMaterial.opacity(presetManager.open ? 1 : 0))
        .animation(.easeInOut(duration: presetManager.open ? 0.5 : 2), value: presetManager.open)
        .frame(minWidth: UIScreen.main.bounds.width, minHeight: UIScreen.main.bounds.height)
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
