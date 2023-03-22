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

var PRESET_OPACITY: Double = 1
var OVERLAY_PRESET_OPACITY: Double = PRESET_OPACITY * 0.5

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
    
    var aboveTheFoldPresets: OrderedDictionary<String, Preset> {
        var map = OrderedDictionary<String, Preset>()
        map[defaultPreset.id] = defaultPreset
        for presetID in defaultPreset.childPresets {
            map[presetID] = allPresets[presetID]
        }
        return map
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
            value: 2,
            mainColor: makeMainColor(2).opacity(PRESET_OPACITY),
            childPresets: [
                "relax"
            ]
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
            value: 2,
            mainColor: makeMainColor(2).opacity(OVERLAY_PRESET_OPACITY),
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
            value: 0,
            mainColor: makeMainColor(0).opacity(PRESET_OPACITY),
            childPresets: [
                "unplug_break",
            ]
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
            value: 0,
            mainColor: makeMainColor(0).opacity(OVERLAY_PRESET_OPACITY),
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
    
    static func makeMainColor(_ _value: Double) -> Color {
        let value = max(min(_value, 7), 0)
        var h, s, b, a: CGFloat
        (h, s, b, a) = (0, 0, 0, 0)
        UIColor(.blue).getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        h = h + Mapping(a: 0, b: 5, c: 0, d: 0.35).map(value)
        s = Mapping(a: 0, b: 5, c: 0.5, d: 0.5).map(value)
        b = Mapping(a: 0, b: 5, c: 0.5, d: 0.6).map(value)
        return Color(UIColor(hue: h, saturation: s, brightness: b, alpha: a))
    }
    
    static func makeParachutePreset(_ presetData: Proxyservice_Preset) -> Preset {
        return Preset(
            name: "Parachute",
            icon: "🪂",
            type: .relax,
            description: "Slow down content after \(Int(presetData.usageMaxHp)) minutes of usage",
            badgeText: "∞",
            presetData: presetData,
            value: 5,
            mainColor: makeMainColor(5).opacity(PRESET_OPACITY),
//            mainColor: .purple.lighter().lighter().lighter().opacity(Mapping(a: 2, b: 10, c: 0.7, d: 0.3).map(presetData.usageMaxHp)),
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
        var ret = OrderedDictionary<String, Preset>()
        for elem in topLevelPresets.elements {
            ret[elem.key] = elem.value
            for child in elem.value.childPresets {
                ret[child] = ProfileManager.presetDefaults[child]
            }
        }
        return ret
    }
    
    var topLevelPresets: OrderedDictionary<String, Preset> {
        [
            "casual": ProfileManager.makeParachutePreset(parachutePresetData),
            "focus": ProfileManager.presetDefaults["focus"]!,
            "unplug": ProfileManager.presetDefaults["unplug"]!,
        ]
    }
    
}
