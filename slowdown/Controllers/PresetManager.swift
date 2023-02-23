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
import Combine

enum StackState {
    case open
    case opening
    case closed
    case closing
}

class PresetManager: ObservableObject {
    struct Provider : Dep {
        func create(r: Registry) -> PresetManager {
            return PresetManager(settingsController: r.resolve(SettingsController.self))
        }
    }
    var settingsController: SettingsController
    var bag = Set<AnyCancellable>()
    init(settingsController: SettingsController) {
        self.settingsController = settingsController
        $open.sink { val in
            if val {
                self.state = .opening
            } else {
                self.state = .closing
            }
        }.store(in: &bag)
        
        $open.debounce(for: .seconds(0.5), scheduler:DispatchQueue.main).sink {val in
            if val {
                self.state = .open
            } else {
                self.state = .closed
            }
        }.store(in: &bag)
    }
    
    @Published var open: Bool = false
    @Published var state: StackState = .closed
    
    
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
            $0.baseRxSpeedTarget = 40e3
            $0.mode = .focus
        },
    ]
    
    func loadPreset(preset: Proxyservice_Preset) async throws {
        try await settingsController.setSettings { settings in
            settings.activePreset = preset
        }
    }
}
