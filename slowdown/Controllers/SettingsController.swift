//
//  SettingsController.swift
//  slowdown
//
//  Created by Sean Lee on 12/18/22.
//

import Foundation
import SwiftUI
import ProxyService

// Operations for changing settings
class SettingsController: ObservableObject {
    struct Provider: ViewModifier {
        @EnvironmentObject var store: SettingsStore
        @EnvironmentObject var service: VPNConfigurationService
        @State var value: SettingsController?
        
        @ViewBuilder
        func body(content: Content)  -> some View {
            let _ = Self._printChanges()
            Group {
                if value == nil {
                    Rectangle().hidden()
                } else {
                    content.environmentObject(value!)
                }
            }.onAppear {
                value = SettingsController(store: store, service: service)
            }
        }
    }
    
    private let store: SettingsStore
    private let service: VPNConfigurationService
    
    init(store: SettingsStore, service: VPNConfigurationService) {
        self.store = store
        self.service = service
    }
    
    public func switchMode(mode: Proxyservice_Mode) {
        if mode != store.settings.mode {
            store.settings.mode = mode
            syncSettings()
        }
    }
    
    public func syncSettings() {
        Task.init(priority: .background) {
            try await service.SetSettings(settings: store.settings)
            try self.store.save()
        }
    }
}
