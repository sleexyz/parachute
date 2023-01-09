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

@main
struct slowdownApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        LoggingSystem.bootstrap(LoggingOSLog.init)
    }
    var body: some Scene {
        WindowGroup {
            Button("Crash") {
              fatalError("Crash was triggered")
            }
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

