//
//  slowdownApp.swift
//  slowdown
//
//  Created by Sean Lee on 1/30/22.
//

import SwiftUI

@main
struct slowdownApp: App {
    @StateObject private var store = SettingsStore()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    SettingsStore.load { result in
                        switch result {
                        case .failure(let error):
                            fatalError(error.localizedDescription)
                        case .success(let settings):
                            store.settings = settings
                        }
                    }
                }
                .environmentObject(store)
        }
    }
}
