//
//  File.swift
//  slowdown
//
//  Created by Sean Lee on 1/28/23.
//

import Foundation
import SwiftUI
import DI
import Controllers

let previewDeps : [any Dep] = [
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
    public struct Provider: MockDep {
        typealias MockT = MockVPNConfigurationService
        public func create(r: Registry) -> VPNConfigurationService {
            return MockVPNConfigurationService()
        }
    }
    override public init() {
        super.init()
    }

    var hasManagerOverride: Bool?
    override public var hasManager: Bool {
        return hasManagerOverride ?? super.hasManager
    }
    func setIsConnected(value: Bool) {
        self.isConnected = value
    }
}
