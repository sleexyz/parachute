import ProxyService
import Foundation

public extension Proxyservice_Settings {
    static var defaultSettings: Proxyservice_Settings {
        var settings = Proxyservice_Settings()
        SettingsMigrations.setDefaults(settings: &settings)
        return settings
    }
}

extension Proxyservice_Settings {
    public var activePreset: Proxyservice_Preset {
        if Date.now < self.overlay.expiry.date {
            return self.overlay.preset
        }
        return self.defaultPreset
    }
}

extension Proxyservice_Settings: CodableMessage {
}
