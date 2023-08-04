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
    VPNLifecycleManager.Provider(),
    SettingsController.Provider(),
    MockVPNConfigurationService.Provider(),
    SettingsStore.Provider()
]

let connectedPreviewDeps : [any Dep] = {
    var value: [any Dep] = [
        ProfileManager.Provider(),
        StateController.Provider(),
    ]
    value.append(contentsOf: previewDeps)
    return value
}()


class MockVPNConfigurationService: VPNConfigurationService {
    struct Provider: MockDep {
        typealias MockT = MockVPNConfigurationService
        func create(r: Registry) -> VPNConfigurationService {
            return MockVPNConfigurationService()
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
