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
import SwiftProtobuf

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
//        if noExpand {
//            return .timingCurve(0.30,0.20,0,1, duration: transitionDuration - 0.1)
//        }
        return .spring(response: 0.55, dampingFraction: 0.825)
//        switch self {
//        // Spring on outer transition states
////        case .cardOpened: return .spring(response: 0.50, dampingFraction: 0.825)
//        case .cardClosed: return .spring(response: 0.50, dampingFraction: 0.825)
//        default: return .timingCurve(0.30,0.20,0,1, duration: transitionDuration - 0.1)
//        }
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
                self.state = .cardClosed
            } else {
                self.state = .cardOpened
            }
        }.store(in: &bag)
        
//        if !noExpand {
//            $open.debounce(for: .seconds(StackState.cardClosing.transitionDuration), scheduler:DispatchQueue.main).sink {val in
//                if val {
//                    self.state = .cardClosed
//                }
//            }.store(in: &bag)
//        }
    }
    
    @Published var open: Bool = false
    @Published var state: StackState = .cardOpened
    
    // Convert to derived publisher
    var activePreset: Preset {
        PresetManager.defaultProfile[settingsStore.activePreset.id]!
    }
    
    static let defaultProfile: OrderedDictionary<String, Preset> = [
        // Default preset
        "focus": Preset(
            name: "Disconnect",
            presetData: Proxyservice_Preset.with {
                $0.id = "focus"
                $0.baseRxSpeedTarget = 40e3
                $0.mode = .focus
            },
            mainColor: Color(red: 0.12, green: 0.10, blue: 0.28)
        ),
        "relax": Preset(
            name: "Connect",
            presetData: Proxyservice_Preset.with {
                $0.id = "relax"
                $0.usageMaxHp = 8
                $0.usageHealRate = 0.5
                $0.mode = .progressive
            },
            mainColor: Color(red: 0.19, green: 0.14, blue: 0.38).lighter(by: 0.4)
        ),
    ]
    
    static func getPreset(id: String) -> Preset {
        return defaultProfile[id]!
    }
    
    func loadPreset(preset: Preset) async throws {
        try await settingsController.setSettings { settings in
            settings.defaultPreset = preset.presetData
        }
    }
    
    func loadOverlay(preset: Preset, secs: Double) async throws {
        if preset.presetData.id == settingsStore.defaultPreset.id {
            try await settingsController.setSettings { settings in
                settings.clearOverlay()
            }
            return
        }
        
        try await settingsController.setSettings { settings in
            settings.overlay = Proxyservice_Overlay.with {
                $0.preset = preset.presetData
                $0.expiry = Google_Protobuf_Timestamp(date: Date(timeIntervalSinceNow: secs))
            }
        }
    }
}
