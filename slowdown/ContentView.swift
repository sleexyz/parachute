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


struct Test: View {
    @EnvironmentObject var service: VPNConfigurationService
    var body: some View {
        VStack {
            Text("\(Double.random(in: 0.0...1.0))")
            Text("\(service.isConnected.description)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Test()
            .modifier(Consumer(type: VPNConfigurationService.self) { service in
                dump(service)
            })
            .modifier(Consumer(type: MockVPNConfigurationService.self) { service in
                service.hasManagerOverride = false
            })
            .modifier(MockVPNConfigurationService.Provider())
            .modifier(SettingsStore.Provider())
//        ContentView()
//            .modifier(AppViewModel.Provider())
//            .modifier(StateController.Provider())
//            .modifier(CheatController.Provider())
//            .modifier(SettingsController.Provider())
//            .modifier(Consumer(type: SettingsStore.self) { service in
//                service.loaded = true
//            })
//            .modifier(Consumer(type: MockVPNConfigurationService.self) { service in
//                service.hasManagerOverride = false
//            })
//            .modifier(MockVPNConfigurationService.Provider())
//            .modifier(SettingsStore.Provider())
//        ContentView()
//            .modifier(AppViewModel.Provider())
//            .modifier(StateController.Provider())
//            .modifier(CheatController.Provider())
//            .modifier(SettingsController.Provider())
//            .modifier(Consumer(type: MockVPNConfigurationService.self) { service in
//                service.hasManagerOverride = true
//            })
//            .modifier(MockVPNConfigurationService.Provider())
//            .modifier(SettingsStore.Provider())
    }
}
