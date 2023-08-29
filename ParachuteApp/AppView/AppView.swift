//
//  AppView.swift
//  slowdown
//
//  Created by Sean Lee on 4/28/22.
//

import SwiftUI
import Controllers
import AppViews

struct AppView: View {
    @EnvironmentObject var store: SettingsStore
    @EnvironmentObject var service: NEConfigurationService
    @EnvironmentObject var controller: SettingsController
    
    var showTransitioning: Bool {
        return service.isTransitioning
    }
    
    var body: some View {
        VStack{
            if !service.isConnected {
                DisconnectedView()
            } else {
                WidgetUpdater {
                    ConnectedView()
                        .provideDeps([
                            ConnectedViewController.Provider()
                        ])
                }
            }
        }
        .disabled(showTransitioning)
        .navigationBarItems(trailing:
                                Spinner(isAnimating: showTransitioning, color: .label, style: .medium)
        )
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
            .consumeDep(MockVPNConfigurationService.self) { value in
                value.setIsConnected(value: true)
            }
            .provideDeps(previewDeps)
    }
}

struct AppViewOff_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
            .consumeDep(MockVPNConfigurationService.self) { value in
                value.setIsConnected(value: false)
            }
            .provideDeps(previewDeps)
    }
}
