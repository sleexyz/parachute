//
//  slowdownApp.swift
//  slowdown
//
//  Created by Sean Lee on 1/30/22.
//

import AppHelpers
import Common
import CommonLoaders
import CommonViews
import Controllers
import FirebaseCore
import OSLog
import ProxyService
import SwiftUI
import OneSignalFramework

let ONESIGNAL_APP_ID = "b1bee63a-1006-42bd-bd66-5a803c64f63c"

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
    func application(_: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        if Env.value == .prod {
            FirebaseApp.configure()
        }
        Task { @MainActor in
            await NEConfigurationService.shared.load()
            if #available(iOS 16.2, *) {
                try SettingsStore.shared.load()
                // TODO: move to MainView
                ActivitiesHelper.shared.start(settings: SettingsStore.shared.settings, isConnected: NEConfigurationService.shared.isConnected)
            }
        }
        NEConfigurationService.shared.registerBackgroundTasks()
        // NEConfigurationService.shared.registerBackgroundTasks()

        // Remove this method to stop OneSignal Debugging
        OneSignal.Debug.setLogLevel(.LL_VERBOSE)
            
        // OneSignal initialization
        OneSignal.initialize(ONESIGNAL_APP_ID, withLaunchOptions: launchOptions)

        // requestPermission will show the native iOS notification permission prompt.
        // We recommend removing the following code and instead using an In-App Message to prompt for notification permission
        OneSignal.Notifications.requestPermission({ accepted in
            print("User accepted notifications: \(accepted)")
        }, fallbackToSettings: true)

        // Login your customer with externalId
        // OneSignal.login("EXTERNAL_ID")
                
        return true
    }
}
