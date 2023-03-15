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
        case .cardClosing: return 0.7
        case .cardClosed: return 0.7
        }
    }
    
    var animation: Animation {
//        if noExpand {
            return .timingCurve(0.30,0.20,0,1, duration: transitionDuration - 0.1)
//        }
//        return .spring(response: 0.55, dampingFraction: 0.825)
//        switch self {
//        // Spring on outer transition states
////        case .cardOpened: return .spring(response: 0.50, dampingFraction: 0.825)
//        case .cardClosed: return .spring(response: 0.50, dampingFraction: 0.825)
//        default: return .timingCurve(0.30,0.20,0,1, duration: transitionDuration - 0.1)
//        }
    }
}

class ProfileManager: ObservableObject {
    struct Provider : Dep {
        func create(r: Registry) -> ProfileManager {
            return ProfileManager(
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
        $presetSelectorOpen.sink { val in
            if val {
                self.state = .cardClosed
            } else {
                self.state = .cardOpened
            }
        }.store(in: &bag)
        
        settingsStore.objectWillChange.receive(subscriber: Subscribers.Sink(receiveCompletion: {_ in }) {
            self.objectWillChange.send()
        })
        
//        if !noExpand {
//            $open.debounce(for: .seconds(StackState.cardClosing.transitionDuration), scheduler:DispatchQueue.main).sink {val in
//                if val {
//                    self.state = .cardClosed
//                }
//            }.store(in: &bag)
//        }
    }
    
    @Published var presetSelectorOpen: Bool = false
    @Published var profileSelectorOpen: Bool = false
    @Published var state: StackState = .cardOpened
    
    
    var activeProfile: Profile {
        Profile.profiles[activeProfileID]!
    }
    
    var activeProfileID: String {
        settingsStore.settings.profileID
    }
    
    // Convert to derived publisher
    var activePreset: Preset {
        Preset.presets[settingsStore.activePreset.id]!
    }
    
    var activeOverlayPreset: Preset? {
        if let presetId = settingsStore.activeOverlayPreset?.id {
            return Preset.presets[presetId]
        }
        return nil
    }
    
    var defaultPreset: Preset {
        return Preset.presets[settingsStore.defaultPreset.id]!
    }
    
    var presets: OrderedDictionary<String, Preset> {
        var map = OrderedDictionary<String, Preset>()
        for presetID in activeProfile.presets {
            map[presetID] = Preset.presets[presetID]
        }
        return map
    }
        
    static func getPreset(id: String) -> Preset {
        return Preset.presets[id]!
    }
    
    func loadProfile(profileID: String) {
        settingsStore.settings.profileID = profileID
        settingsStore.settings.defaultPreset = Profile.profiles[profileID]!.defaultPreset.presetData
        settingsStore.settings.clearOverlay()
        settingsController.syncSettings()
    }
    
    
    // TODO: make synchronous for usage via withAnimation
    func loadOverlay(preset: Preset) async throws {
        if preset.presetData.id == settingsStore.defaultPreset.id {
            settingsStore.settings.clearOverlay()
            settingsController.syncSettings()
            return
        }
        
        settingsStore.settings.overlay = Proxyservice_Overlay.with {
            $0.preset = preset.presetData
            $0.expiry = Google_Protobuf_Timestamp(date: Date(timeIntervalSinceNow: preset.overlayDurationSecs!))
        }
        settingsController.syncSettings()
    }
}
