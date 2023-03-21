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

var ANIMATION_SECS: Double = 0.35

var ANIMATION: Animation = .timingCurve(0.30,0.20,0,1, duration: ANIMATION_SECS * 1.7)
var ANIMATION_SHORT: Animation = .timingCurve(0.30,0.20,0,1, duration: ANIMATION_SECS)

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
        
        settingsStore.$settings
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &bag)
    }
    
    @Published var presetSelectorOpen: Bool = false
    @Published var profileSelectorOpen: Bool = false
    
    
    var activeProfile: Profile {
        Profile.profiles[activeProfileID]!
    }
    
    var activeProfileID: String {
        settingsStore.settings.profileID
    }
    
    // Convert to derived publisher
    var activePreset: Preset {
        allPresets[settingsStore.activePreset.id]!
    }
    
    var activeOverlayPreset: Preset? {
        if let presetId = settingsStore.activeOverlayPreset?.id {
            return allPresets[presetId]
        }
        return nil
    }
    
    var defaultPreset: Preset {
        return allPresets[settingsStore.defaultPreset.id]!
    }
    
    var presets: OrderedDictionary<String, Preset> {
        var map = OrderedDictionary<String, Preset>()
        for presetID in activeProfile.presets {
            map[presetID] = allPresets[presetID]
        }
        return map
    }
        
    func loadProfile(profileID: String) {
        settingsStore.settings.profileID = profileID
        settingsStore.settings.defaultPreset = allPresets[Profile.profiles[profileID]!.defaultPresetID]!.presetData
        settingsStore.settings.clearOverlay()
        settingsController.syncSettings()
    }
    
    // Inclusive of loadOverlay
    func loadPreset(preset: Preset) {
        if preset.overlayDurationSecs != nil {
            return loadOverlay(preset: preset)
        }
        settingsStore.settings.defaultPreset = preset.presetData
        settingsStore.settings.clearOverlay()
        settingsController.syncSettings()
    }
    
    func loadOverlay(preset: Preset) {
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
    
    // Writes through to parachute preset
    func loadParachutePreset(preset: Preset) {
        loadPreset(preset: preset)
        settingsStore.settings.parachutePreset = preset.presetData
        settingsController.syncSettings()
    }
    
    static var presetDefaults: OrderedDictionary<String, Preset> = [
        "focus": Preset(
            name: "Detox",
            icon: "🫧",
            type: .focus,
            description: "Slows down content",
            badgeText: "∞",
            presetData: Proxyservice_Preset.with {
                $0.id = "focus"
                $0.baseRxSpeedTarget = 40e3
                $0.mode = .focus
            },
            mainColor: Profile.profiles["detox"]!.color.opacity(0.6)
        ),
        "relax": Preset(
            name: "Break",
            type: .relax,
            description: "Temporarily disable slowing",
            badgeText: "3 min",
            presetData: Proxyservice_Preset.with {
                $0.id = "relax"
                $0.baseRxSpeedTarget = .infinity
                $0.mode = .focus
            },
            mainColor: Profile.profiles["detox"]!.color.opacity(0.3),
            overlayDurationSecs: 3 * 60
        ),
        "unplug": Preset(
            name: "Sleep",
            icon: "🌌",
            type: .focus,
            description: "Slows down all internet",
            badgeText: "∞",
            presetData: Proxyservice_Preset.with {
                $0.id = "unplug"
                $0.baseRxSpeedTarget = 40e3
                $0.mode = .focus
                $0.trafficRules = Proxyservice_TrafficRules.with {
                    $0.matchAllTraffic = true
                }
            },
            mainColor: Profile.profiles["unplug"]!.color.opacity(0.6)
        ),
        "unplug_break": Preset(
            name: "Break",
            type: .relax,
            description: "Temporarily disable slowing",
            badgeText: "1 min",
            presetData: Proxyservice_Preset.with {
                $0.id = "unplug_break"
                $0.baseRxSpeedTarget = .infinity
                $0.mode = .focus
                $0.trafficRules = Proxyservice_TrafficRules.with {
                    $0.matchAllTraffic = true
                }
            },
            mainColor: Profile.profiles["unplug"]!.color.opacity(0.3),
            overlayDurationSecs: 1 * 60
        ),
        "casual": makeParachutePreset(ProfileManager.makeParachutePresetData(hp: 5)),
    ]
    
    static func makeParachutePresetData(hp: Double) -> Proxyservice_Preset {
        return Proxyservice_Preset.with {
            $0.id = "casual"
            $0.usageMaxHp = hp
            $0.usageHealRate = 1
            $0.mode = .progressive
        }
    }
    
    static func makeParachutePreset(_ presetData: Proxyservice_Preset) -> Preset {
        return Preset(
            name: "Parachute — \(Int(presetData.usageMaxHp)) min",
            icon: "🪂",
            type: .relax,
            description: "Slow down content after \(Int(presetData.usageMaxHp)) minutes of usage",
            badgeText: "∞",
            presetData: presetData,
            mainColor: Profile.profiles["casual"]!.color.opacity(Mapping(a: 2, b: 10, c: 1, d: 0.5).map(presetData.usageMaxHp)),
            expandedBody:  AnyView(ParachutePresetPicker())
        )
    }
    
    var parachutePresetData: Proxyservice_Preset {
        if settingsStore.settings.hasParachutePreset {
            return settingsStore.settings.parachutePreset
        }
        return ProfileManager.presetDefaults["casual"]!.presetData
    }
    
    
    var allPresets: OrderedDictionary<String, Preset> {
        [
            "focus": ProfileManager.presetDefaults["focus"]!,
            "relax": ProfileManager.presetDefaults["relax"]!,
            "unplug": ProfileManager.presetDefaults["unplug"]!,
            "unplug_break": ProfileManager.presetDefaults["unplug_break"]!,
            "casual": ProfileManager.makeParachutePreset(parachutePresetData)
        ]
    }
}
