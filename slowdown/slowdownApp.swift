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

@main
struct slowdownApp: App {
    init() {
        LoggingSystem.bootstrap(LoggingOSLog.init)
    }
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
