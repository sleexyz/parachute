//
//  Setting.swift
//  slowdown
//
//  Created by Sean Lee on 12/6/22.
//

import Foundation
import ProxyService
import SwiftProtobuf
import SwiftUI
import Logging
import Combine
import DI


struct HandlerWrapper {
    let handler: () -> Void
    let id: UUID
}

public class SettingsStore: ObservableObject {
    public struct Provider : Dep {
        public func create(r: Registry) -> SettingsStore {
            return .shared
        }
        public init() {}
    }

    public static let shared = SettingsStore()
    
    @Published public var settings: Proxyservice_Settings = {
        var settings = Proxyservice_Settings()
        SettingsMigrations.setDefaults(settings: &settings)
        return settings
    }()

    @Published public var savedSettings: Proxyservice_Settings? = nil
    
    @Published public var loaded = false
    
    private let logger = Logger(label: "industries.strange.slowdown.SettingsStore")
    
    private var bag = Set<AnyCancellable>()
    
    init() {
        logger.info("init settings store")
        $settings.dropFirst().sink {
            self.logger.info("Changed: \($0.debugDescription)")
        }.store(in: &bag)
    }
    
    public var activePreset: Proxyservice_Preset {
        return activePresetBinding.wrappedValue
    }
    
    var defaultPreset: Proxyservice_Preset {
        return defaultPresetBinding.wrappedValue
    }
    
    var isOverlayActive: Bool {
        if Date.now < settings.overlay.expiry.date {
            return true
        }
        return false
    }
    
    var activeOverlayPreset: Proxyservice_Preset? {
        if self.isOverlayActive {
            return self.settings.overlay.preset
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
                await self.setActivePreset(value:value)
            }
        }
    }
    
    var defaultPresetBinding: Binding<Proxyservice_Preset> {
        Binding {
            return self.settings.defaultPreset
        } set: { value in
            Task {
                await self.setDefaultPreset(value:value)
            }
        }
    }
    
    private static func fileUrl() throws -> URL {
        guard let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.industries.strange.slowdown") else {
            fatalError("could not get shared app group directory.")
        }
        return groupURL.appendingPathComponent("settings.data")
    }
    
    public func waitForLoaded() async -> () {
        await withCheckedContinuation {continuation in
            if self.loaded {
                continuation.resume(returning: ())
            } else {
                let cancellable  = self.$loaded.first().sink { _ in
                    continuation.resume(returning: ())
                }
                cancellable.store(in: &self.bag)
            }
        }
   }
    
    public func load() throws {
        do {
            try loadFromFile()
        } catch CocoaError.fileNoSuchFile {
            try save()
            return try loadFromFile()
        }
    }
    
    private func loadFromFile() throws {
        let fileUrl = try SettingsStore.fileUrl()
        let file = try FileHandle(forReadingFrom: fileUrl)
        var newSettings = try Proxyservice_Settings(serializedData: file.availableData)
        // run migrations
        SettingsMigrations.upgradeToLatestVersion(settings: &newSettings)
        
        let upgradedNewSettings = newSettings
        Task {
            await self.setSettings(value: upgradedNewSettings)
            await self.setLoaded(value: true)
        }
    }
    
    @MainActor
    private func setSettings(value: Proxyservice_Settings) {
        self.settings = value
    }
    
    @MainActor
    private func setActivePreset(value: Proxyservice_Preset) {
        if isOverlayActive {
            self.settings.overlay.preset = value
        } else {
            self.settings.defaultPreset = value
        }
    }
    
    @MainActor
    private func setDefaultPreset(value: Proxyservice_Preset) {
        self.settings.defaultPreset = value
    }
    
    @MainActor
    private func setLoaded(value: Bool) {
        self.loaded = value
    }
    
    public func save() throws {
        let data = try self.settings.serializedData()
        let outfile = try SettingsStore.fileUrl()
        try data.write(to:outfile)
        savedSettings = settings
    }
}