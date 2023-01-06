//
//  Setting.swift
//  slowdown
//
//  Created by Sean Lee on 12/6/22.
//

import Foundation
import ProxyService
import SwiftProtobuf

class SettingsStore: ObservableObject {
    static let shared = SettingsStore()
    
    private var onLoadFns: Array<() -> Void> = []
    
    @Published var settings: Proxyservice_Settings = {
        var settings = Proxyservice_Settings()
        SettingsMigrations.setDefaults(settings: &settings)
        return settings
    }()
    @Published var loaded = false
    
    @MainActor
    func setCheatSettings(expiry: Date, speed: Double) {
        settings.temporaryRxSpeedExpiry = Google_Protobuf_Timestamp(date: expiry)
        settings.temporaryRxSpeedTarget = speed
    }
    
    
    private static func fileUrl() throws -> URL {
        guard let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.industries.strange.slowdown") else {
            fatalError("could not get shared app group directory.")
        }
        return groupURL.appendingPathComponent("settings.data")
    }
    
    func onLoad(fn: @escaping () -> Void) {
        onLoadFns.append(fn)
    }
    
    func load() throws {
        do {
            try loadFromFile()
            for fn in onLoadFns {
                fn()
            }
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
    private func setLoaded(value: Bool) {
        self.loaded = value
    }
    
    public func save() throws {
        let data = try self.settings.serializedData()
        let outfile = try SettingsStore.fileUrl()
        try data.write(to:outfile)
    }
            
}
