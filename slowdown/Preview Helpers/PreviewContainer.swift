//
//  File.swift
//  slowdown
//
//  Created by Sean Lee on 1/28/23.
//

import Foundation
import SwiftUI

let previewDeps : [any Dep] = [
    AppViewModel.Provider(),
    StateController.Provider(),
    CheatController.Provider(),
    SettingsController.Provider(),
    MockVPNConfigurationService.Provider(),
    SettingsStore.Provider()
]

class MockVPNConfigurationService: VPNConfigurationService {
    struct Provider: Dep {
        typealias T = VPNConfigurationService
        func create(r: Registry) -> VPNConfigurationService {
            let value = MockVPNConfigurationService(store: r.resolve(SettingsStore.self))
            r.bind(key: ServiceKey(serviceType: MockVPNConfigurationService.self), service: value)
            return value
        }
    }
    
    var hasManagerOverride: Bool?
    override var hasManager: Bool {
        return hasManagerOverride ?? super.hasManager
    }
    func setIsConnected(value: Bool) {
        self.isConnected = value
    }
}
