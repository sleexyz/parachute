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
import FamilyControls

struct ContentView: View {
    @EnvironmentObject var store: SettingsStore
    @EnvironmentObject var service: NEConfigurationService
    @EnvironmentObject var onboardingViewController: OnboardingViewController
    @Environment(\.scenePhase) var scenePhase
    @StateObject var familyControls = AuthorizationCenter.shared
    
    var testOnlyAuthorizationStatusOverride: AuthorizationStatus? = nil
    var authorizationStatus: AuthorizationStatus {
        testOnlyAuthorizationStatusOverride ?? familyControls.authorizationStatus
    }
    
    
    private let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ContentView")
    
    @ViewBuilder
    var body: some View {
        Group {
            if !onboardingViewController.isOnboardingCompleted {
                OnboardingView()
            } else if authorizationStatus != .approved {
                FamilyControlsView()
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

struct ContentViewIntro_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .consumeDep(OnboardingViewController.self) { controller in
                controller.isOnboardingCompleted = false
            }
            .provideDeps(previewDeps)
        
        
       
    }
}
struct ContentViewFamilyControls_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .consumeDep(SettingsStore.self) { service in
                service.loaded = true
            }
            .consumeDep(OnboardingViewController.self) { controller in
                controller.isOnboardingCompleted = true
            }
            .consumeDep(MockVPNConfigurationService.self) { service in
                service.isInstalledMockOverride =  false
            }
            .provideDeps(previewDeps)
    
    }
}

struct ContentViewContentFilter_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(testOnlyAuthorizationStatusOverride: .approved)
            .consumeDep(OnboardingViewController.self) { controller in
                controller.isOnboardingCompleted = true
            }
            .consumeDep(MockVPNConfigurationService.self) { service in
                service.isInstalledMockOverride = true
            }
            .provideDeps(previewDeps)
    
    }
}



