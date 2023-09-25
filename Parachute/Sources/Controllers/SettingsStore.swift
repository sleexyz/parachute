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

    public func load() throws {
        do {
            try loadFromFile()
            logger.info("loaded settings from file")
        } catch CocoaError.fileNoSuchFile {
            try save()
            try loadFromFile()
            logger.info("created settings file")
            return
        }
    }

    private func loadFromFile() throws {
        var newSettings = try read()
        // run migrations
        SettingsMigrations.upgradeToLatestVersion(settings: &newSettings)

        let upgradedNewSettings = newSettings
        Task {
            await self.setSettings(value: upgradedNewSettings)
            await self.setLoaded(value: true)
        }
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
    func save() throws {
        let data = try settings.serializedData()
        let outfile = try SettingsStore.fileUrl()
        try data.write(to: outfile)
        savedSettings = settings
    }
}
