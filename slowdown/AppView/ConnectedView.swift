//
//  ConnectedView.swift
//  slowdown
//
//  Created by Sean Lee on 2/15/23.
//

import Foundation
import SwiftUI

struct ConnectedView: View {
    @EnvironmentObject var vpnLifecycleManager: VPNLifecycleManager
    @EnvironmentObject var service: VPNConfigurationService
    var body: some View {
        VStack {
            VStack {
                PrimaryButton(title: "Pause VPN connection for one hour", action: vpnLifecycleManager.pauseConnection, isLoading: service.isTransitioning)
            }.padding()
            Spacer()
            ProgressiveModeView()
            Spacer()
        }
    }
}
