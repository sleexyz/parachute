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
import DI
import Models
import RangeMapping
import AppHelpers

var PRESET_OPACITY: Double = 0.8
var OVERLAY_PRESET_OPACITY: Double = PRESET_OPACITY * 0.3

public class ProfileManager: ObservableObject {
    public struct Provider : Dep {
        public func create(r: Registry) -> ProfileManager {
            let instance = ProfileManager(
                settingsStore: r.resolve(SettingsStore.self),
                settingsController: r.resolve(SettingsController.self)
            )
            ProfileManager.shared = instance
            return instance
        }
        public init() {}
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

    public static var shared: ProfileManager? = nil
    
    @Published public var presetSelectorOpen: Bool = false
    @Published public var profileSelectorOpen: Bool = false

    public var overlayTimer: Timer? = nil

    // TODO: Convert to derived publisher. Right now all views need to also listen to settingsStore.$settings
    public var activePreset: Preset {
        allPresets[settingsStore.activePreset.id]!
    }
    
    var activeOverlayPreset: Preset? {
        if let presetId = settingsStore.activeOverlayPreset?.id {
            return allPresets[presetId]
        }
        return nil
    }
    
    public var defaultPreset: Preset {
        return allPresets[settingsStore.defaultPreset.id]!
    }
    
    public var presets: OrderedDictionary<String, Preset> {
        var map = OrderedDictionary<String, Preset>()
        map[defaultPreset.id] = defaultPreset
        for presetID in defaultPreset.childPresets {
            map[presetID] = allPresets[presetID]
        }
        return map
    }

        
    @MainActor
    public func loadPreset(preset: Preset, overlay: Preset? = nil) async throws -> () {
        settingsStore.settings.defaultPreset = preset.presetData
        if let overlay = overlay {
            if overlay.overlayDurationSecs != nil {
                settingsStore.settings.overlay = Proxyservice_Overlay.with {
                    $0.preset = overlay.presetData
                    $0.expiry = Google_Protobuf_Timestamp(date: Date(timeIntervalSinceNow: overlay.overlayDurationSecs!))
                }
                try await settingsController.syncSettings()

                overlayTimer?.invalidate()
                overlayTimer = Timer.scheduledTimer(withTimeInterval: overlay.overlayDurationSecs!, repeats: false) { _ in
                    Task { @MainActor in
                        self.settingsStore.settings.clearOverlay()
                        try await self.settingsController.syncSettings(reason: "Overlay expired")
                        if #available(iOS 16.2, *) {
                            await ActivitiesHelper.shared.update(settings: self.settingsStore.settings)
                        }
                    }
                }

                return
            } 
        } 
        settingsStore.settings.clearOverlay()
        try await settingsController.syncSettings()
    }

    // Inclusive of loadOverlay
    public func loadPresetLegacy(preset: Preset) async throws -> () {
        if preset.overlayDurationSecs != nil {
            if let parentPresetID = preset.parentPreset {
                try await loadPreset(preset: ProfileManager.presetDefaults[parentPresetID]!, overlay: preset)
                return
            }
        }
        try await loadPreset(preset: preset)
    }
    
    // Writes through to parachute preset
    public func loadParachutePreset(preset: Preset) {
        Task.init(priority: .background) {
            try await loadPreset(preset: preset)
            settingsStore.settings.parachutePreset = preset.presetData
            try await settingsController.syncSettings()
        }
    }
    
    public static var presetDefaults: OrderedDictionary<String, Preset> = [
        "focus": .focus,
        "relax": .relax,
        "casual": makeParachutePreset(ProfileManager.makeParachutePresetData(hp: 5)),
    ]
    
    public static func makeParachutePresetData(hp: Double) -> Proxyservice_Preset {
        return Proxyservice_Preset.with {
            $0.id = "casual"
            $0.usageMaxHp = hp
            $0.usageHealRate = 1
            $0.mode = .progressive
        }
    }
    
    static func makeMainColor(_ value: Double) -> Color {
        var h, s, b, a: CGFloat
        (h, s, b, a) = (0, 0, 0, 0)
        UIColor(.blue).getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        h = h + Mapping(a: 0, b: 5, c: 0.1, d: 0.35).map(value)
        s = Mapping(a: 0, b: 5, c: 0.5, d: 0.5).map(value)
        b = Mapping(a: 0, b: 5, c: 0.4, d: 0.7).map(value)
        return Color(UIColor(hue: h, saturation: s, brightness: b, alpha: a))
    }
    
    public static func makeParachutePreset(_ presetData: Proxyservice_Preset) -> Preset {
        return Preset(
            name: "Parachute",
            icon: "🪂",
            type: .relax,
            description: "Slow down content after \(Int(presetData.usageMaxHp)) minutes of usage",
            badgeText: "∞",
            presetData: presetData,
            mainColor: makeMainColor(5).opacity(PRESET_OPACITY)
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
    
    public var topLevelPresets: OrderedDictionary<String, Preset> {
        [
            "casual": ProfileManager.makeParachutePreset(parachutePresetData),
            "focus": ProfileManager.presetDefaults["focus"]!,
        ]
    }
    
}
