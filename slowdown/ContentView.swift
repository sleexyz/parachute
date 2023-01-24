//
//  ContentView.swift
//  slowdown
//
//  Created by Sean Lee on 1/30/22.
//

import SwiftUI

import Foundation
import Logging

struct ContentView: View {
    @EnvironmentObject var store: SettingsStore
    @EnvironmentObject var service: VPNConfigurationService
    
    private let logger: Logger = Logger(label: "industries.strange.slowdown.ContentView")
    
    @ViewBuilder
    var body: some View {
        let _ = Self._printChanges()
            if !store.loaded  {
                SplashView(text: "Loading settings...")
            } else if service.isInitializing {
                SplashView(text: "Loading VPN state...")
            } else if !service.hasManager {
                SetupView()
            } else {
                AppView()
                    .modifier(AppViewModel.Provider())
                    .modifier(StateController.Provider())
                    .modifier(CheatController.Provider())
                    .modifier(SettingsController.Provider())
            }
    }
}

struct ContentViewLoader: View {
    private let logger = Logger(label: "industries.strange.slowdown.ContentViewLoader")
    
    var body: some View {
        let _ = Self._printChanges()
        ContentView()
                .modifier(Consumer(type: SettingsStore.self) { store in
                    do {
                        try store.load()
                        logger.info("loaded!")
                    } catch {
                        logger.info("error loading settings: \(error)")
                    }
                })
                .modifier(VPNConfigurationService.Provider())
                .modifier(SettingsStore.Provider())
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .modifier(Consumer(type: SettingsStore.self) { service in
                service.loaded = true
            })
            .modifier(Consumer(type: MockVPNConfigurationService.self) { service in
                service.hasManagerOverride = false
            })
            .modifier(MockVPNConfigurationService.Provider())
            .modifier(SettingsStore.Provider())
        ContentView()
            .modifier(Consumer(type: MockVPNConfigurationService.self) { service in
                service.hasManagerOverride = true
            })
            .modifier(MockVPNConfigurationService.Provider())
            .modifier(SettingsStore.Provider())
    }
}
