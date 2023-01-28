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
    struct Provider: MockDep {
        typealias MockT = MockVPNConfigurationService
        func create(r: Registry) -> VPNConfigurationService {
            return MockVPNConfigurationService(store: r.resolve(SettingsStore.self))
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
