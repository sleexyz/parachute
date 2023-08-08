//
//  slowdownApp.swift
//  slowdown
//
//  Created by Sean Lee on 1/30/22.
//

import SwiftUI
import ProxyService
import Logging
import LoggingOSLog
import Firebase
import Common
import Controllers
import CommonLoaders

@main
struct slowdownApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    private let logger = Logger(label: "industries.strange.slowdown.slowdownApp")
    
    init() {
        LoggingSystem.bootstrap(LoggingOSLog.init)
    }
    
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
        if Env.value == .prod {
            FirebaseApp.configure()
        }
        Task { @MainActor in
            await VPNConfigurationService.shared.load()
        }
        VPNConfigurationService.shared.registerBackgroundTasks()
        return true
    }
}

