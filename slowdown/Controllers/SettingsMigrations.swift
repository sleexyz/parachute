//
//  SettingsMigrations.swift
//  slowdown
//
//  Created by Sean Lee on 1/5/23.
//

import Foundation
import ProxyService

let LATEST_VERSION = 2

final class SettingsMigrations {
    private static var migrations: [Int: (inout Proxyservice_Settings) -> Void] = [
        2: { settings in
            settings.activePreset = Proxyservice_Preset.with {
                $0.usageHealRate = 0.5
                $0.usageMaxHp = 6
            }
            settings.version = 2
        },
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

