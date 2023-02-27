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
import OrderedCollections

enum StackState {
    case cardOpened
    case cardClosing
    case cardClosed
    
    var transitionDuration: Double {
        switch self {
        case .cardOpened: return 0.7
        case .cardClosing: return 0.5
        case .cardClosed: return 0.7
        }
    }
    
    var animation: Animation {
        if noExpand {
            return .timingCurve(0.30,0.20,0,1, duration: transitionDuration - 0.1)
        }
        switch self {
        // Spring on outer transition states
//        case .cardOpened: return .spring(response: 0.50, dampingFraction: 0.825)
        case .cardClosed: return .spring(response: 0.50, dampingFraction: 0.825)
        default: return .timingCurve(0.30,0.20,0,1, duration: transitionDuration - 0.1)
        }
    }
}

class PresetManager: ObservableObject {
    struct Provider : Dep {
        func create(r: Registry) -> PresetManager {
            return PresetManager(
                settingsStore: r.resolve(SettingsStore.self),
                settingsController: r.resolve(SettingsController.self)
            )
        }
    }
    var settingsStore: SettingsStore
    var settingsController: SettingsController
    var bag = Set<AnyCancellable>()
    init(settingsStore: SettingsStore, settingsController: SettingsController) {
        self.settingsStore = settingsStore
        self.settingsController = settingsController
        $open.sink { val in
            if val {
                if noExpand {
                    self.state = .cardClosed
                } else {
                    self.state = .cardClosing
                }
            } else {
                self.state = .cardOpened
            }
        }.store(in: &bag)
        
        if !noExpand {
            $open.debounce(for: .seconds(StackState.cardClosing.transitionDuration), scheduler:DispatchQueue.main).sink {val in
                if val {
                    self.state = .cardClosed
                }
            }.store(in: &bag)
        }
    }
    
    @Published var open: Bool = false
    @Published var state: StackState = .cardOpened
    
    // Convert to derived publisher
    var activePreset: Preset {
        PresetManager.defaultPresets[settingsStore.settings.activePreset.id]!
    }
    
    static let defaultPresets: OrderedDictionary<String, Preset> = [
        "relax": Preset(
            name: "Connect",
            presetData: Proxyservice_Preset.with {
                $0.id = "relax"
                $0.usageMaxHp = 20
                $0.usageHealRate = 0.5
                $0.mode = .progressive
            }
//            mainColor: Color(red: 0.87, green: 0.3, blue: 0.3)
        ),
        "focus": Preset(
            name: "Disconnect",
            presetData: Proxyservice_Preset.with {
                $0.id = "focus"
                $0.baseRxSpeedTarget = 40e3
                $0.mode = .focus
            }
        )
    ]
    
    static func getPreset(id: String) -> Preset {
        return defaultPresets[id]!
    }
    
    func loadPreset(preset: Preset) async throws {
        try await settingsController.setSettings { settings in
            settings.activePreset = preset.presetData
        }
    }
}
