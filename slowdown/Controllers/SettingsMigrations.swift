//
//  SettingsMigrations.swift
//  slowdown
//
//  Created by Sean Lee on 1/5/23.
//

import Foundation
import ProxyService

let LATEST_VERSION = 5

final class SettingsMigrations {
    private static var migrations: [Int: (inout Proxyservice_Settings) -> Void] = [
        2: { settings in
            settings.defaultPreset = ProfileManager.presetDefaults.elements[0].value.presetData
            settings.version = 2
        },
        3: { settings in
            settings.profileID = Profile.profiles.elements[0].key
            settings.version = 3
        },
        4: { settings in
            settings.profileID = Profile.profiles.elements[0].key
            settings.defaultPreset = ProfileManager.presetDefaults[Profile.profiles[settings.profileID]!.presets.elements[0]]!.presetData
            settings.version = 4
        },
        5: { settings in
            if settings.defaultPreset.id == "supercasual" {
                settings.defaultPreset.id = "casual"
            }
            if settings.defaultPreset.id == "ultracasual" {
                settings.defaultPreset.id = "casual"
            }
            settings.version = 5
        }
    ]
    public static func setDefaults(settings: inout Proxyservice_Settings, from: Int = 0) {
        for i in from...LATEST_VERSION {
            migrations[i]?(&settings)
        }
    }
    
    public static func upgradeToLatestVersion(settings: inout Proxyservice_Settings) {
        if settings.version == LATEST_VERSION {
            return
        }
        setDefaults(settings: &settings, from: Int(settings.version) + 1)
    }
}

