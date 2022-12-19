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
    private let logger: Logger
    init() {
        LoggingSystem.bootstrap(LoggingOSLog.init)
        self.logger = Logger(label: "com.strangeindustries.slowdown.App")
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    SettingsStore.shared.load { result in
                        switch result {
                        case .failure(let error):
                            fatalError(error.localizedDescription)
                        case .success():
                            logger.info("loaded settings")
                        }
                    }
                }
        }
    }
}
