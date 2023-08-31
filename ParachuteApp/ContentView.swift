//
//  ContentView.swift
//  slowdown
//
//  Created by Sean Lee on 1/30/22.
//

import SwiftUI

import Foundation
import OSLog
import Controllers
import CommonViews
import AppViews

struct ContentView: View {
    @EnvironmentObject var store: SettingsStore
    @EnvironmentObject var service: NEConfigurationService
    @Environment(\.scenePhase) var scenePhase
    
    private let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ContentView")
    
    @ViewBuilder
    var body: some View {
        Group {
            // Check UserDefaults for first run
            if !OnboardingViewController.shared.isOnboardingCompleted {
                OnboardingView()
            } else if !store.loaded  {
                SplashView(text: "Loading settings...")
            } else if !service.isLoaded {
                SplashView(text: "Loading VPN state...")
            } else if !service.isInstalled {
                SetupView()
            } else {
                AppView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .preferredColorScheme(.dark)
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
                service.isInstalledMockOverride =  false
            }
            .provideDeps(previewDeps)
        
        
        ContentView()
            .consumeDep(OnboardingViewController.self) { controller in
                controller.currentPage = 1
            }
            .provideDeps(previewDeps)

        
        ContentView()
            .consumeDep(MockVPNConfigurationService.self) { service in
                service.isInstalledMockOverride = true
            }
            .provideDeps(previewDeps)
    }
}
