//
//  ContentView.swift
//  slowdown
//
//  Created by Sean Lee on 1/30/22.
//

import SwiftUI

import Foundation
import Logging


struct ContentView: View {
    private let logger: Logger = Logger(label: "industries.strange.slowdown.ContentView")
    @ObservedObject var service: VPNConfigurationService = .shared
    @ObservedObject var store: SettingsStore = .shared
    private let appViewModel: AppViewModel = AppViewModel()
    
    init() {
        do {
            try store.load()
            self.logger.info("loaded!")
        } catch {
            self.logger.info("error loading settings: \(error)")
        }
    }
    
    var body: some View {
        if !store.loaded || service.isInitializing {
            return AnyView(SplashView())
        }
        
        if service.hasManager {
            return AnyView(AppView()
                .environmentObject(appViewModel))
            
        } else {
            return AnyView(SetupView())
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
