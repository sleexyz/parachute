//
//  DisconnectedView.swift
//  slowdown
//
//  Created by Sean Lee on 2/15/23.
//

import AppViews
import Common
import Controllers
import Foundation
import SwiftProtobuf
import SwiftUI

struct DisconnectedView: View {
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var settingsController: SettingsController

    @EnvironmentObject var vpnLifecycleManager: VPNLifecycleManager
    @EnvironmentObject var service: NEConfigurationService

    var buttonTitle: String {
        return "Enable Content Filter"
    }

    var body: some View {
        VStack {
            Spacer()
            Button {
                vpnLifecycleManager.startConnection()
            } label: {
                Text(buttonTitle)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .tint(.parachuteOrange)
            .buttonStyle(.bordered)
            Spacer()
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
