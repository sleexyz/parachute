//
//  Setting.swift
//  slowdown
//
//  Created by Sean Lee on 12/6/22.
//

import Foundation
import ProxyService

class SettingsStore: ObservableObject {
    @Published var settings: Proxyservice_Settings = makeDefaultSettings()
    
    static func makeDefaultSettings() -> Proxyservice_Settings {
        var settings = Proxyservice_Settings()
        settings.baseRxSpeedTarget = 200000
        return settings
    }
    
    static let shared = SettingsStore()
    
    private static func fileUrl() throws -> URL {
        guard let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.industries.strange.slowdown") else {
            fatalError("could not get shared app group directory.")
        }
        return groupURL.appendingPathComponent("settings.data")
    }
    
    func load(completion: @escaping (Result<(),Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileUrl = try SettingsStore.fileUrl()
                guard let file = try? FileHandle(forReadingFrom: fileUrl) else {
                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                    return
                }
                let newSettings = try Proxyservice_Settings(serializedData: file.availableData)
                DispatchQueue.main.async {
                    self.settings = newSettings
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func save(completion: @escaping(Result<Int, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try self.settings.serializedData()
                let outfile = try SettingsStore.fileUrl()
                try data.write(to:outfile)
                DispatchQueue.main.async {
                    completion(.success(1))
                }
            
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
