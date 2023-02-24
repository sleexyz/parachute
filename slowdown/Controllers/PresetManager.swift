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
    case cardOpening
    case cardOpened
    case cardClosing
    case cardClosed
    
    var transitionDuration: Double {
        let base = 0.6
        switch self {
        case .cardOpening: return base * 0.5
        case .cardOpened: return base
        case .cardClosing: return base
        case .cardClosed: return base
        default: return base
        }
    }
    
    var animation: Animation {
        switch self {
        // Spring on outer transition states
        case .cardOpening: return .spring(response: 0.50, dampingFraction: 0.825)
        case .cardClosed: return .spring(response: 0.50, dampingFraction: 0.825)
        default: return .timingCurve(0.30,0.20,0,1, duration: transitionDuration - 0.1)
        }
    }
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
                self.state = .cardClosing
            } else {
                self.state = .cardOpening
            }
        }.store(in: &bag)
        
        $open.debounce(for: .seconds(StackState.cardClosing.transitionDuration), scheduler:DispatchQueue.main).sink {val in
            if val {
                self.state = .cardClosed
            }
        }.store(in: &bag)
        
        $open.debounce(for: .seconds(StackState.cardOpening.transitionDuration), scheduler:DispatchQueue.main).sink {val in
            if !val {
                self.state = .cardOpened
            }
        }.store(in: &bag)
    }
    
    @Published var open: Bool = false
    @Published var state: StackState = .cardOpened
    
    
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
