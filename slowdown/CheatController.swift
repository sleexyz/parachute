//
//  CheatController.swift
//  slowdown
//
//  Created by Sean Lee on 12/7/22.
//

import NetworkExtension
import Foundation
import os
import UserNotifications

final class CheatController: ObservableObject {
    private let service: VPNConfigurationService = .shared
    static let shared = CheatController()
    
    @Published private var cheatDeadline: Date?
    
    var isCheating: Bool {
        return cheatDeadline != nil && cheatDeadline! > Date()
    }
    
    var cheatTimeLeft: Int {
        if cheatDeadline == nil {
            return 0
        }
        return Int(cheatDeadline!.timeIntervalSinceNow)
    }
    
    func startCheat() async throws {
        try await self.service.startCheat()
        
        DispatchQueue.main.async {
            self.cheatDeadline = Date().addingTimeInterval(60)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(60)) {
                    os_log("invalidating cheat time")
            self.cheatDeadline = nil
        }
        
        let _ = try await enableNotifications()
        try await self.sendMessage(title: "Cheat ended", body: "", fromNow: 60)
    }
    
    func sendMessage(title: String, body: String, fromNow: TimeInterval) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: fromNow, repeats: false)
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                                            content: content, trigger: trigger)
        let notificationCenter = UNUserNotificationCenter.current()
        return try await notificationCenter.add(request)
    }
    
    func enableNotifications() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        let enabled = try await withCheckedThrowingContinuation { continuation in
            center.getNotificationSettings { settings in
                continuation.resume(with: .success(settings.alertSetting == .enabled))
            }
        }
        if enabled {
            return true
        }
        let granted: Bool = try await withCheckedThrowingContinuation { continuation in
            center.requestAuthorization(options: [.alert]) { granted, error in
                if let error = error {
                    continuation.resume(with: .failure(error))
                    return
                } else {
                    continuation.resume(with: .success(granted))
                }
            }
        }
        return granted
    }
    
}
