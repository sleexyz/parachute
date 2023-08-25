import ProxyService
import Foundation

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

    var shouldAllowSocialMedia: Bool {
        return self.activePreset.baseRxSpeedTarget == .infinity
    }
}


extension Proxyservice_Settings: CodableMessage {

}
