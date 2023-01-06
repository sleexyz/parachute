//
//  SettingsMigrations.swift
//  slowdown
//
//  Created by Sean Lee on 1/5/23.
//

import Foundation
import ProxyService

final class SettingsMigrations {
    private static var migrations: [(inout Proxyservice_Settings) -> Void] = [
        // 0
        { settings in
            settings.baseRxSpeedTarget = 100000
            // We don't set version because it's already default zeroed
        },
        // 1
        { settings in
            settings.usageHealRate = 0.5
            settings.usageMaxHp = 6
            settings.version = 1
        },
    ]
    public static func setDefaults(settings: inout Proxyservice_Settings, from: Int = 0) {
        for i in from...(migrations.count - 1) {
            migrations[i](&settings)
        }
    }
    
    public static func upgradeToLatestVersion(settings: inout Proxyservice_Settings) {
        if settings.version == migrations.count - 1 {
            return
        }
        setDefaults(settings: &settings, from: Int(settings.version) + 1)
    }
}

