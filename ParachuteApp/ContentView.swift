//
//  ContentView.swift
//  slowdown
//
//  Created by Sean Lee on 1/30/22.
//

import SwiftUI

import Foundation
import Logging
import Controllers

struct ContentView: View {
    @EnvironmentObject var store: SettingsStore
    @EnvironmentObject var service: VPNConfigurationService
    @Environment(\.scenePhase) var scenePhase
    
    private let logger: Logger = Logger(label: "industries.strange.slowdown.ContentView")
    
    @ViewBuilder
    var body: some View {
        Group {
            if !store.loaded  {
                SplashView(text: "Loading settings...")
            } else if service.isInitializing {
                SplashView(text: "Loading VPN state...")
            } else if !service.hasManager {
                SetupView()
            } else {
                AppView()
            }
        }
        .onChange(of: scenePhase) { phase in
            // Reload settings when app becomes active
            // in case they were changed in the widget
            if phase == .active {
                // logger.info("active")
                do {
                    try store.load()
                    logger.info("loaded!")
                } catch {
                    logger.info("error loading settings: \(error)")
                }
            }
        }
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
