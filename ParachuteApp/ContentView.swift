//
//  ContentView.swift
//  slowdown
//
//  Created by Sean Lee on 1/30/22.
//

import SwiftUI

import AppViews
import CommonViews
import Controllers
import FamilyControls
import Foundation
import OSLog

struct ContentView: View {
    @EnvironmentObject var store: SettingsStore
    @EnvironmentObject var service: NEConfigurationService
    @EnvironmentObject var onboardingViewController: OnboardingViewController
    // @Environment(\.scenePhase) var scenePhase
    @StateObject var familyControls = AuthorizationCenter.shared

    var testOnlyAuthorizationStatusOverride: AuthorizationStatus? = nil
    var authorizationStatus: AuthorizationStatus {
        testOnlyAuthorizationStatusOverride ?? familyControls.authorizationStatus
    }

    private let logger: Logger = .init(subsystem: Bundle.main.bundleIdentifier!, category: "ContentView")

    @ViewBuilder
    var body: some View {
        Group {
            if !onboardingViewController.isOnboardingCompleted {
                OnboardingView()
            } else if authorizationStatus != .approved {
                FamilyControlsView()
            } else if !store.loaded {
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
                service.isInstalledMockOverride = false
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
