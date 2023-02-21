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
                .padding(.bottom, 60)
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
            caption: "Disconnect from VPN for 1 hour",
            backgroundColor: Color.gray
        ) {
            
        }
    }
}

struct CardSelector: View {
    @EnvironmentObject var presetManager: PresetManager
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var stateController: StateController
    @EnvironmentObject var vpnLifecycleManager: VPNLifecycleManager
    @State var open: Bool = false
    var body: some View {
        VStack {
            if open {
                PauseCard()
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            vpnLifecycleManager.pauseConnection()
                        }
                ForEach(PresetManager.defaultPresets) {preset in
                    if preset.id != settingsStore.activePreset.id {
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
                            presetManager.loadPreset(preset: preset)
                            self.open = false
                        }
                    }
                }
            }
            ProgressiveCard(model: PresetViewModel(preset: settingsStore.activePreset)) {
                if stateController.isSlowing {
                    LockedHealButton()
                        .padding(.top, 20)
                }
            }
                .onTapGesture {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    self.open = !self.open
                }
        }
        .onTapBackground(enabled: self.open) {
            self.open = false
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
