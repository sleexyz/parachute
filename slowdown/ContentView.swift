//
//  ContentView.swift
//  slowdown
//
//  Created by Sean Lee on 1/30/22.
//

import SwiftUI

import Foundation
import Logging
import Inject

struct ContentView: View {
    @EnvironmentObject var store: SettingsStore
    @EnvironmentObject var service: VPNConfigurationService
    
    private let logger: Logger = Logger(label: "industries.strange.slowdown.ContentView")
    @ObservedObject private var i0 = Inject.observer
    
    @ViewBuilder
    var body: some View {
        if !store.loaded  {
            SplashView(text: "Loading settings...")
        } else if service.isInitializing {
            SplashView(text: "Loading VPN state...")
        } else if !service.hasManager {
            SetupView()
                .enableInjection()
        } else {
            AppView()
                .provideDeps([
                    AppViewModel.Provider(),
                ])
                .enableInjection()
        }
    }
}

struct ContentViewLoader: View {
    private let logger = Logger(label: "industries.strange.slowdown.ContentViewLoader")
    
    var body: some View {
        ContentView()
            .consumeDep(SettingsStore.self) { store in
                do {
                    try store.load()
                    logger.info("loaded!")
                } catch {
                    logger.info("error loading settings: \(error)")
                }
            }
            .provideDeps([
                VPNLifecycleManager.Provider(),
                SettingsController.Provider(),
                VPNConfigurationService.Provider(),
                SettingsStore.Provider()
            ])
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .consumeDep(SettingsStore.self) { service in
                service.loaded = true
            }
            .consumeDep(MockVPNConfigurationService.self) { service in
                service.hasManagerOverride =  false
            }
            .provideDeps(previewDeps)
        
        ContentView()
            .consumeDep(MockVPNConfigurationService.self) { service in
                service.hasManagerOverride = true
            }
            .provideDeps(previewDeps)
    }
}
