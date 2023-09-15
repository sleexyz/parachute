import Combine
import DeviceActivity
import DI
import FamilyControls
import ManagedSettings
import OSLog
import SwiftUI

public class AppController: ObservableObject {
    let name: String
    public lazy var store: ManagedSettingsStore = .init(named: ManagedSettingsStore.Name(rawValue: name))
    var bag = Set<AnyCancellable>()
    
    @Published public var selection: FamilyActivitySelection


    init(name: String) {
        self.name = name
        
        let key = "\(name)Selection"
        
        self._selection = .init(initialValue: {
            let data = UserDefaults.standard.object(forKey: key )
            if let data = data as? Data {
                return try! PropertyListDecoder().decode(FamilyActivitySelection.self, from: data)
            }
            return FamilyActivitySelection()
        }())
        
        
        $selection.dropFirst().sink { value in
            do {
                let data = try PropertyListEncoder().encode(value)
                UserDefaults.standard.set(data, forKey: key)
            } catch {}
        }.store(in: &bag)
    }
    
    public var enabled: Binding<Bool> {
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
    
    public func reenable() {
        store.shield.applications = selection.applicationTokens
    }
    public func disable() {
        store.shield.applications = []
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

    public var instagram = AppController(name: "instagram")
    public var tiktok = AppController(name: "tiktok")

    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "DeviceActivityController")

    init() {}

    public func initiateMonitoring() {
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0, second: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
            repeats: true,
            warningTime: DateComponents(second: 15)
        )

        let center = DeviceActivityCenter()
        let event = DeviceActivityEvent(
            applications: instagram.selection.applicationTokens,
            threshold: DateComponents(minute: 1)
        )
        let eventName = DeviceActivityEvent.Name("MyApp.SomeEventName")


        do {
            try center.startMonitoring(
                .init("daily"), 
                during: schedule,
                events: [
                    eventName: event
                ]
            )
            debugPrint("Monitoring started for the day")
        } catch {
            print("Could not start monitoring \(error)")
        }
    }

    public func stopMonitoring() {
        let center = DeviceActivityCenter()

        center.stopMonitoring([.init("daily")])
        debugPrint("Monitoring stopped for the day")
    }
}
