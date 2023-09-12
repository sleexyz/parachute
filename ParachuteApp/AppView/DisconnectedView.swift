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
        if !service.isConnected {
            "Enable Parachute"
        } else {
            "Re-enable Parachute"
        }
    }

    var caption: String {
        if !service.isConnected {
            return "Disabled."
        } else {
            // let dateFormatter = DateFormatter()
            // dateFormatter.dateStyle = .none
            // dateFormatter.timeStyle = .short

            // let disabledUntil = settingsStore.settings.disabledUntil.date
            // let formattedDate = dateFormatter.string(from: disabledUntil)
            return "Disabled for 1 hour."
        }
    }

    var body: some View {
        VStack {
            Spacer()
            Text(caption)
                .font(.system(size: 20, weight: .regular, design: .rounded))
//                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
            Spacer()
            Button {
                if !service.isConnected {
                    vpnLifecycleManager.startConnection()
                } else {
                    vpnLifecycleManager.reenable()
                }
            } label: {
                Text(buttonTitle)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .tint(.parachuteOrange)
            .buttonStyle(.bordered)

            Spacer()

            Button {
                vpnLifecycleManager.stopConnection()
            } label: {
                Text("Disable indefinitely")
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .tint(.secondary)
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
