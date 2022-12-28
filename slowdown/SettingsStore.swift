//
//  Setting.swift
//  slowdown
//
//  Created by Sean Lee on 12/6/22.
//

import Foundation
import ProxyService

class SettingsStore: ObservableObject {
    @Published var settings: Proxyservice_Settings = {
        var settings = Proxyservice_Settings()
        settings.baseRxSpeedTarget = 56000
        return settings
    }()
    @Published var loaded = false
    
    static let shared = SettingsStore()
    
    private static func fileUrl() throws -> URL {
        guard let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.industries.strange.slowdown") else {
            fatalError("could not get shared app group directory.")
        }
        return groupURL.appendingPathComponent("settings.data")
    }
    
    func load() throws {
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
        let newSettings = try Proxyservice_Settings(serializedData: file.availableData)
        Task {
            await self.setSettings(value: newSettings)
            await self.setLoaded(value: true)
        }
    }
    
    @MainActor
    func setSettings(value: Proxyservice_Settings) {
        self.settings = value
        
    }
    
    @MainActor
    func setLoaded(value: Bool) {
        self.loaded = value
        
    }
    
    func save() throws {
        let data = try self.settings.serializedData()
        let outfile = try SettingsStore.fileUrl()
        try data.write(to:outfile)
    }
            
}
