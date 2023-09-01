//
//  slowdownApp.swift
//  slowdown
//
//  Created by Sean Lee on 1/30/22.
//

import SwiftUI
import ProxyService
import FirebaseCore
import Common
import Controllers
import CommonLoaders
import AppHelpers
import OSLog
import CommonViews

@main
struct slowdownApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        Fonts.registerFonts()
    }
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "slowdownApp")
    
    var body: some Scene {
        WindowGroup {
            ControllersLoader {
                ContentView()
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // if Env.value == .prod {
        FirebaseApp.configure()
        // }
        Task { @MainActor in
            await NEConfigurationService.shared.load()
            if #available(iOS 16.2, *) {
                try SettingsStore.shared.load()
                // TODO: move to MainView
                ActivitiesHelper.shared.start(settings: SettingsStore.shared.settings, isConnected: NEConfigurationService.shared.isConnected)
            }
        }
        NEConfigurationService.shared.registerBackgroundTasks()
        return true
    }
}

