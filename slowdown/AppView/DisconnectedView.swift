//
//  DisconnectedView.swift
//  slowdown
//
//  Created by Sean Lee on 2/15/23.
//

import Foundation
import SwiftUI
import SwiftProtobuf
import Common

struct DisconnectedView: View {
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var model: AppViewModel
    @EnvironmentObject var vpnLifecycleManager: VPNLifecycleManager
    @EnvironmentObject var service: VPNConfigurationService
    
    var buttonTitle: String {
        if settingsStore.settings.isPaused() {
            return "Resume VPN connection"
        }
        return "Start VPN connection"
    }
    
    var body: some View {
        VStack {
            Spacer()
            PrimaryButton(title: buttonTitle, action: vpnLifecycleManager.toggleConnection, isLoading: service.isTransitioning)
            Spacer()
            if Env.value == .dev {
                Toggle(isOn: $settingsStore.settings.debug, label: { Text("Debug")})
                    .disabled(service.isTransitioning)
                    .onChange(of: settingsStore.settings.debug) { _ in
                        model.saveSettings()
                    }
            }
        }.padding()
    }
}

struct DisconnectedView_Previews: PreviewProvider {
    static var previews: some View {
        DisconnectedView()
            .consumeDep(MockVPNConfigurationService.self) { value in
                value.setIsConnected(value: false)
            }
            .provideDeps(previewDeps)
    }
}

struct DisconnectedViewPaused_Previews: PreviewProvider {
    static var previews: some View {
        DisconnectedView()
            .consumeDep(MockVPNConfigurationService.self) { value in
                value.setIsConnected(value: false)
            }
            .consumeDep(SettingsController.self) { value in
                Task {
                    try await value.setSettings { settings in
                        settings.pauseExpiry = Google_Protobuf_Timestamp(date: Date(timeIntervalSinceNow: 5 * 60))
                    }
                }
            }
            .provideDeps(previewDeps)
    }
}