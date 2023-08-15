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

