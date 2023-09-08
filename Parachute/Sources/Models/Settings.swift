import Foundation
import ProxyService
import SwiftUI

public extension Proxyservice_Settings {
    static var defaultSettings: Proxyservice_Settings {
        var settings = Proxyservice_Settings()
        SettingsMigrations.setDefaults(settings: &settings)
        return settings
    }
}

public extension Proxyservice_Settings {
    var activePreset: Proxyservice_Preset {
        if Date.now < overlay.expiry.date {
            return overlay.preset
        }
        return defaultPreset
    }

    var isInScrollSession: Bool {
        return activePreset.baseRxSpeedTarget == .infinity
    }

    func isAppEnabled(app: Proxyservice_AppType) -> Bool {
        apps[Int32(app.rawValue)] ?? false
    }

    mutating func setAppEnabled(app: Proxyservice_AppType, value: Bool) {
        apps[Int32(app.rawValue)] = value
    }
}

extension Proxyservice_Settings: CodableMessage {}
