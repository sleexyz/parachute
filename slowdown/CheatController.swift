//
//  CheatController.swift
//  slowdown
//
//  Created by Sean Lee on 12/7/22.
//

import SwiftUI
import NetworkExtension
import Foundation
import os
import UserNotifications

final class CheatController: ObservableObject {
    private let service: VPNConfigurationService = .shared
    @ObservedObject private var store: SettingsStore = .shared
    private var settingsController: SettingsController = .shared
    private var timer: Timer?
    
    @Published
    public var cheatTimeLeft: Int = 0
    
    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.sampleCheatTimeLeft()
        }
        self.sampleCheatTimeLeft()
    }
    
    static let shared = CheatController()
    
    var cheatExpiry: Date? {
        if store.settings.temporaryRxSpeedExpiry.seconds == 0 {
            return nil
        }
        return store.settings.temporaryRxSpeedExpiry.date
    }
    
    
    var isCheating: Bool {
        return cheatExpiry != nil && cheatExpiry! > Date()
    }
    
    @MainActor
    private func sampleCheatTimeLeft() {
            self.cheatTimeLeft = Int(cheatExpiry?.timeIntervalSinceNow ?? 0)
    }
    
    func startCheat() async throws {
        self.store.setCheatSettings(expiry: Date() + 60, speed: Double.infinity)
        self.settingsController.syncSettings()
        
        let _ = try await enableNotifications()
        self.clearNotifications()
        try await self.sendMessage(title: "Cheat ended", body: "", fromNow: 60)
    }
    
    func clearNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
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
