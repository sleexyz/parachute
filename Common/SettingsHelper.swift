//
//  SettingsHelper.swift
//  Common
//
//  Created by Sean Lee on 2/6/23.
//

import Foundation

public class SettingsHelper {
    private static func fileUrl() throws -> URL {
        guard let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.industries.strange.slowdown") else {
            fatalError("could not get shared app group directory.")
        }
        return groupURL.appendingPathComponent("settings.data")
    }
    
    public static func loadSettingsData() throws -> Data {
        let file = try FileHandle(forReadingFrom: SettingsHelper.fileUrl())
        return file.availableData
    }
}