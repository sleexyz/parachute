//
//  Setting.swift
//  slowdown
//
//  Created by Sean Lee on 12/6/22.
//

import Foundation

class SettingsStore: ObservableObject {
    @Published var settings: Bool = false
    
    static let shared = SettingsStore()
    
    private static func fileUrl() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                       in: .userDomainMask,
                                       appropriateFor: nil,
                                       create: false)
            .appendingPathComponent("settings.data")
    }
    
    static func load(completion: @escaping (Result<Bool,Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileUrl = try fileUrl()
                guard let file = try? FileHandle(forReadingFrom: fileUrl) else {
                    DispatchQueue.main.async {
                        completion(.success(false))
                    }
                    return
                }
                let settings = try JSONDecoder().decode(Bool.self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(settings))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    static func save(settings: Bool, completion: @escaping(Result<Int, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(settings)
                let outfile = try fileUrl()
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
