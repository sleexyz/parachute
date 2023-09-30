//
//  Setting.swift
//  slowdown
//
//  Created by Sean Lee on 12/6/22.
//

import Combine
import DI
import Foundation
import Models
import OSLog
import ProxyService
import SwiftProtobuf
import SwiftUI

struct HandlerWrapper {
    let handler: () -> Void
    let id: UUID
}

public class SettingsStore: ObservableObject {
    public struct Provider: Dep {
        public func create(r _: Registry) -> SettingsStore {
            .shared
        }

        public init() {}
    }

    public static let id = Bundle.main.bundleIdentifier!
    public static let shared = SettingsStore()

    @Published public var settings: Proxyservice_Settings = .defaultSettings

    @Published public var savedSettings: Proxyservice_Settings? = nil

    @Published public var loaded = false

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SettingsStore")

    private var bag = Set<AnyCancellable>()

    init() {
        logger.info("init settings store")
        $settings.dropFirst().sink {
            self.logger.info("Changed: \($0.debugDescription)")
            // if !$0.hasOverlay {
            //     WidgetCenter.shared.reloadAllTimelines()
            // }
        }.store(in: &bag)
    }

    public func makeBinding<T>(keyPath: WritableKeyPath<Proxyservice_Settings, T>) -> Binding<T> {
        Binding {
            self.settings[keyPath: keyPath]
        } set: { value in
            Task { @MainActor in
                var newSettings = self.settings
                newSettings[keyPath: keyPath] = value
                self.setSettings(value: newSettings)
            }
        }
    }

    public func makeBoolBinding(keyPath: WritableKeyPath<Proxyservice_Settings, Bool>) -> Binding<Bool> {
        makeBinding(keyPath: keyPath)
    }

    public func makeScheduleTimeBinding(keyPath: WritableKeyPath<Proxyservice_Settings, Proxyservice_ScheduleTime>) -> Binding<Date> {
        let hourBinding = makeBinding(keyPath: keyPath.appending(path: \.hour))
        let minuteBinding = makeBinding(keyPath: keyPath.appending(path: \.minute))

        return Binding {
            var dateComponents = DateComponents()
            dateComponents.hour = Int(hourBinding.wrappedValue)
            dateComponents.minute = Int(minuteBinding.wrappedValue)
            return Calendar.current.date(from: dateComponents)!
        } set: { value in
            let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: value)
            hourBinding.wrappedValue = Int32(dateComponents.hour!)
            minuteBinding.wrappedValue = Int32(dateComponents.minute!)
        }
    }

    public var activePreset: Proxyservice_Preset {
        activePresetBinding.wrappedValue
    }

    var defaultPreset: Proxyservice_Preset {
        defaultPresetBinding.wrappedValue
    }

    public var isOverlayActive: Bool {
        if Date.now < settings.overlay.expiry.date {
            return true
        }
        return false
    }

    var activeOverlayPreset: Proxyservice_Preset? {
        if isOverlayActive {
            return settings.overlay.preset
        }
        return nil
    }

    public var activePresetBinding: Binding<Proxyservice_Preset> {
        Binding {
            if let preset = self.activeOverlayPreset {
                return preset
            }
            return self.settings.defaultPreset
        } set: { value in
            Task {
                await self.setActivePreset(value: value)
            }
        }
    }

    var defaultPresetBinding: Binding<Proxyservice_Preset> {
        Binding {
            self.settings.defaultPreset
        } set: { value in
            Task {
                await self.setDefaultPreset(value: value)
            }
        }
    }

    let quickSessionSecsOptions = [
        30,
        45,
        60,
    ]

    let longSessionSecsOptions = [
        3 * 60,
        5 * 60,
        10 * 60,
        15 * 60,
    ]

    public var quickSessionSecsAdjacentOptions: (Int?, Int?) {
        getAdjacentOptions(value: Int(settings.quickSessionSecs), options: quickSessionSecsOptions)
    }

    public var longSessionSecsAdjacentOptions: (Int?, Int?) {
        getAdjacentOptions(value: Int(settings.longSessionSecs), options: longSessionSecsOptions)
    }

    private func getAdjacentOptions(value: Int, options: [Int]) -> (Int?, Int?) {
        var before: Int? = nil
        var after: Int? = nil

        //  Get closest index
        let diffs = options.map { abs($0 - value) }
        var closestIndex = 0
        for (i, diff) in diffs.enumerated() {
            if diff < diffs[closestIndex] {
                closestIndex = i
            }
        }

        // get adjacent indexes
        return (
            closestIndex > 0 ? options[closestIndex - 1] : nil,
            closestIndex < options.count - 1 ? options[closestIndex + 1] : nil
        )
    }

    private static func fileUrl() throws -> URL {
        guard let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.industries.strange.slowdown") else {
            fatalError("could not get shared app group directory.")
        }
        return groupURL.appendingPathComponent("settings.data")
    }

    public func waitForLoaded() async {
        await withCheckedContinuation { continuation in
            if self.loaded {
                continuation.resume(returning: ())
            } else {
                let cancellable = self.$loaded.first().sink { _ in
                    continuation.resume(returning: ())
                }
                cancellable.store(in: &self.bag)
            }
        }
    }

    // TODO: test this migration
    public func load() throws {
        do {
            guard let data = SettingsStore.userDefaults.data(forKey: SettingsStore.key) else {
                throw CocoaError(.fileNoSuchFile)
            }

            let newSettings = try Proxyservice_Settings(serializedData: data)
            migrateAndWriteSettings(settings: newSettings)
            Task {
                await self.setSettings(value: self.settings)
                await self.setLoaded(value: true)
            }

            // try loadFromFile()
            logger.info("loaded settings from userDefaults")
        } catch CocoaError.fileNoSuchFile {
            do {
                let newSettings = try read()
                migrateAndWriteSettings(settings: newSettings)
                Task {
                    await self.setSettings(value: self.settings)
                    await self.setLoaded(value: true)
                }
                try save() // write through
                logger.info("loaded settings file from file")
                return
            } catch {
                migrateAndWriteSettings(settings: self.settings)
                Task {
                    await self.setSettings(value: self.settings)
                    await self.setLoaded(value: true)
                }
                try save()
                logger.info("created settings file")
            }
        }
    }

    private func migrateAndWriteSettings(settings: Proxyservice_Settings) {
        var newSettings = settings
        SettingsMigrations.upgradeToLatestVersion(settings: &newSettings)
        self.settings = newSettings
    }

    public func read() throws -> Proxyservice_Settings {
        let fileUrl = try SettingsStore.fileUrl()
        let file = try FileHandle(forReadingFrom: fileUrl)
        return try Proxyservice_Settings(serializedData: file.availableData)
    }

    @MainActor
    private func setSettings(value: Proxyservice_Settings) {
        settings = value
    }

    @MainActor
    private func setActivePreset(value: Proxyservice_Preset) {
        if isOverlayActive {
            settings.overlay.preset = value
        } else {
            settings.defaultPreset = value
        }
    }

    @MainActor
    private func setDefaultPreset(value: Proxyservice_Preset) {
        settings.defaultPreset = value
    }

    @MainActor
    private func setLoaded(value: Bool) {
        loaded = value
    }

    // NOTE: use SettingsController.save() instead of this method
    public func save() throws {
        let data = try settings.serializedData()
        let outfile = try SettingsStore.fileUrl()
        try data.write(to: outfile)
        // Write to UserDefaults
        SettingsStore.userDefaults.set(data, forKey: SettingsStore.key)
        savedSettings = settings
    }

    static var userDefaults: UserDefaults = .init(suiteName: "group.industries.strange.slowdown")!
    static var key = "settings"
}
