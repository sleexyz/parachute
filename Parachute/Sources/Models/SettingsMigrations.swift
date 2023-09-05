//
//  SettingsMigrations.swift
//  slowdown
//
//  Created by Sean Lee on 1/5/23.
//

import Foundation
import ProxyService

public final class SettingsMigrations {
    private static var migrations: [Int: (inout Proxyservice_Settings) -> Void] = [
        2: { settings in
            settings.defaultPreset = .focus
        },
        5: { settings in
            if settings.defaultPreset.id == "supercasual" {
                settings.defaultPreset.id = "casual"
            }
            if settings.defaultPreset.id == "ultracasual" {
                settings.defaultPreset.id = "casual"
            }
        },
        7: { settings in
            settings.setAppEnabled(app: .instagram, value: true)
            settings.setAppEnabled(app: .tiktok, value: true)
            settings.setAppEnabled(app: .twitter, value: true)
        },
        8: { settings in
            settings.quickSessionSecs = 30
            settings.longSessionSecs = 60 * 5 // 5 minutes
        },
        9: {
            settings in
            settings.algorithm = .proportional
        }
    ]

    public static var LATEST_VERSION: Int {
        migrations.keys.max()!
    }

    public static func setDefaults(settings: inout Proxyservice_Settings, from: Int = 0) {
        for i in from...SettingsMigrations.LATEST_VERSION {
            if let migration = migrations[i] {
                migration(&settings)
                settings.version = Int32(i)
            }
        }
    }
    
    public static func upgradeToLatestVersion(settings: inout Proxyservice_Settings) {
        if settings.version == SettingsMigrations.LATEST_VERSION {
            return
        }
        setDefaults(settings: &settings, from: Int(settings.version) + 1)
    }
}

