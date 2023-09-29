import Combine
import DeviceActivity
import DI
import FamilyControls
import ManagedSettings
import OSLog
import ProxyService
import SwiftUI

public class AppDeviceActivityController: ObservableObject {
    let name: Proxyservice_AppType
    private lazy var store: ManagedSettingsStore = .init(named: ManagedSettingsStore.Name(rawValue: "\(name)"))
    var bag = Set<AnyCancellable>()

    @Published public var selection: FamilyActivitySelection

    var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "AppDeviceActivityController")

    static var userDefaults: UserDefaults = .init(suiteName: "group.industries.strange.slowdown")!

    static func getSelection(name: Proxyservice_AppType) -> FamilyActivitySelection {
        let data = userDefaults.value(forKey: name.familyActivitySelectionKey)
        if let data = data as? Data {
            do {
                return try PropertyListDecoder().decode(FamilyActivitySelection.self, from: data)
            } catch {}
        }
        return FamilyActivitySelection()
    }

    init(appType: Proxyservice_AppType) {
        name = appType

        _selection = .init(initialValue: AppDeviceActivityController.getSelection(name: name))
        $selection.dropFirst().sink { value in
            do {
                let data = try PropertyListEncoder().encode(value)
                AppDeviceActivityController.userDefaults.set(data, forKey: self.name.familyActivitySelectionKey)
                AppDeviceActivityController.userDefaults.synchronize()
            } catch {}
        }.store(in: &bag)
    }

    public var isPaired: Bool {
        selection.applicationTokens.count > 0
    }

    // TODO: convert to binding
    public func setTokens(_ tokens: Set<ApplicationToken>) {
        selection.applicationTokens = tokens
    }

    public var shieldEnabled: Binding<Bool> {
        Binding(
            get: { !(self.store.shield.applications?.isEmpty ?? true) },
            set: {
                // TODO: see if I have to manually trigger update
                if $0 {
                    self.store.shield.applications = self.selection.applicationTokens
                } else {
                    self.store.shield.applications = []
                }
            }
        )
    }

    public func unblock() {
        store.shield.applications = []
    }

    public func block() {
        logger.info("blocking \(self.selection.applicationTokens, privacy: .public)")
        logger.info("blocked: \(self.store.shield.applications?.debugDescription ?? "", privacy: .public)")
        store.shield.applications = selection.applicationTokens
    }
}
