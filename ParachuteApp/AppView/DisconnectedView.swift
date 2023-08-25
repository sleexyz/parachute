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
import Controllers

struct DisconnectedView: View {
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var settingsController: SettingsController

    @EnvironmentObject var vpnLifecycleManager: VPNLifecycleManager
    @EnvironmentObject var service: NEConfigurationService
    
    var buttonTitle: String {
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
                        Task.init(priority: .background) {
                            try await  settingsController.syncSettings()
                        }
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
