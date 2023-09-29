import FamilyControls
import ManagedSettings
import ProxyService
import SwiftUI

public struct AppController {
    public static let instagram: AppController = .init(appType: .instagram, settingsStore: .shared, settingsController: .shared)
    public static let tiktok: AppController = .init(appType: .tiktok, settingsStore: .shared, settingsController: .shared)
    public static let twitter: AppController = .init(appType: .twitter, settingsStore: .shared, settingsController: .shared)
    public static let youtube: AppController = .init(appType: .youtube, settingsStore: .shared, settingsController: .shared)
    public static let facebook: AppController = .init(appType: .facebook, settingsStore: .shared, settingsController: .shared)

    public static var apps: [AppController] {
        [.instagram, .tiktok, .twitter, .youtube, .facebook]
    }

    public let appType: Proxyservice_AppType

    let settingsStore: SettingsStore
    let settingsController: SettingsController

    public let dac: AppDeviceActivityController

    public init(appType: Proxyservice_AppType, settingsStore: SettingsStore, settingsController: SettingsController) {
        self.appType = appType
        self.settingsStore = settingsStore
        self.settingsController = settingsController
        self.dac = AppDeviceActivityController(appType: appType)
    }

    public var isEnabled: Binding<Bool> {
        Binding<Bool>(
            get: { settingsStore.settings.isAppEnabled(app: appType) },
            set: { newValue in
                settingsStore.settings.setAppEnabled(app: appType, value: newValue)
                Task { @MainActor in
                    try await settingsController.syncSettings(reason: "\(appType) toggle")
                }
            }
        )
    }
}
