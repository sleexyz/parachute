import Combine
import DeviceActivity
import DI
import FamilyControls
import ManagedSettings
import OSLog
import SwiftUI
import ProxyService

public class AppController: ObservableObject {
    let name: Proxyservice_AppType
    public lazy var store: ManagedSettingsStore = .init(named: ManagedSettingsStore.Name(rawValue: "\(name)"))
    var bag = Set<AnyCancellable>()

    @Published public var selection: FamilyActivitySelection

    var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "AppController")

    static var userDefaults: UserDefaults = UserDefaults(suiteName: "group.industries.strange.slowdown")!

    static func getInitialSelection(name: String) -> FamilyActivitySelection {
        let key = "\(name)Selection"
        let data = userDefaults.value(forKey: key)
        if let data = data as? Data {
            do {
                return try PropertyListDecoder().decode(FamilyActivitySelection.self, from: data)
            } catch {
            
            }
        }
        return FamilyActivitySelection()
    }
    
    init(appType: Proxyservice_AppType) {
        self.name = appType
        
        let key = "\(appType)Selection"
        
        self._selection = .init(initialValue: AppController.getInitialSelection(name: "\(appType)"))
        $selection.dropFirst().sink { value in
            do {
                let data = try PropertyListEncoder().encode(value)
                AppController.userDefaults.set(data, forKey: key)
                AppController.userDefaults.synchronize()

            } catch {}
        }.store(in: &bag)
    }
    
    public var shieldEnabled: Binding<Bool> {
        Binding(
            get: { !(self.store.shield.applications?.isEmpty ?? true) },
            set: {
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

public class DeviceActivityController: ObservableObject {
    public struct Provider: Dep {
        public func create(r _: Registry) -> DeviceActivityController {
            .shared
        }

        public init() {}
    }

    public static let shared = DeviceActivityController()

    public var instagram = AppController(appType: .instagram)
    public var tiktok = AppController(appType: .tiktok)
    public var twitter = AppController(appType: .twitter)
    public var youtube = AppController(appType: .youtube)
    public var facebook = AppController(appType: .facebook)

    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "DeviceActivityController")

    init() {}
    
    // TODO: unblock all the apps
    public func unblock() {
        instagram.unblock()
    }

    // TODO: block all the apps
    public func block() {
        instagram.block()
    }

    public func initiateMonitoring(timeInterval: TimeInterval) {
        let now = Date()
        let after = now.addingTimeInterval(-1)
        let schedule = DeviceActivitySchedule(
            intervalStart: Calendar.current.dateComponents([.hour, .minute, .second], from: now),
            intervalEnd: Calendar.current.dateComponents([.hour, .minute, .second], from: after),
            repeats: true
//            warningTime: DateComponents(second: 15)
        )

        let center = DeviceActivityCenter()
        let event = DeviceActivityEvent(
            applications: instagram.selection.applicationTokens,
            threshold: DateComponents(second: Int(timeInterval))
        )
        
        let eventName = DeviceActivityEvent.Name("foo")

        do {
            try center.startMonitoring(
                .init("daily"), 
                during: schedule,
                 events: [
                     eventName: event
                 ]
            )
            logger.info("Monitoring started for the day")
        } catch {
            logger.error("Could not start monitoring \(error)")
        }
    }

    public func stopMonitoring() {
        let center = DeviceActivityCenter()

        center.stopMonitoring([.init("daily")])
        logger.info("Monitoring stopped for the day")
    }
}
