import ProxyService
import Foundation
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
        if Date.now < self.overlay.expiry.date {
            return self.overlay.preset
        }
        return self.defaultPreset
    }

    var isInScrollSession: Bool {
        return self.activePreset.baseRxSpeedTarget == .infinity
    }

    func isAppEnabled(app: Proxyservice_AppType) -> Bool {
        self.apps[Int32(app.rawValue)] ?? false
    }
    
    mutating func setAppEnabled(app: Proxyservice_AppType, value: Bool) {
        self.apps[Int32(app.rawValue)] = value
    }
}


extension Proxyservice_Settings: CodableMessage {

}
