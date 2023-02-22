//
//  PresetManager.swift
//  slowdown
//
//  Created by Sean Lee on 2/18/23.
//

import Foundation
import ProxyService
import SwiftUI
import Logging

class PresetManager: ObservableObject {
    struct Provider : Dep {
        func create(r: Registry) -> PresetManager {
            return PresetManager(settingsController: r.resolve(SettingsController.self))
        }
    }
    var settingsController: SettingsController
    init(settingsController: SettingsController) {
        self.settingsController = settingsController
    }
    
    @Published var open: Bool = false
    
    static let defaultPresets: [Proxyservice_Preset] = [
        Proxyservice_Preset.with {
            $0.id = "relax"
            $0.name = "Relax"
            $0.usageMaxHp = 20
            $0.usageHealRate = 0.5
            $0.mode = .progressive
        },
        Proxyservice_Preset.with {
            $0.id = "focus"
            $0.name = "Focus"
            $0.usageMaxHp = 2
            $0.usageHealRate = 0.5
            $0.mode = .progressive
        },
    ]
    
    func loadPreset(preset: Proxyservice_Preset) {
        Task {
            try await settingsController.setSettings { settings in
                settings.activePreset = preset
            }
        }
    }
}
