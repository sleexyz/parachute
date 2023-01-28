//
//  CheatController.swift
//  slowdown
//
//  Created by Sean Lee on 12/7/22.
//

import SwiftUI
import NetworkExtension
import Foundation
import UserNotifications
import Logging

final class CheatController: ObservableObject {
    struct Provider: Dep {
        func create(resolver: Resolver) -> CheatController {
            return CheatController(
                store: resolver.resolve(SettingsStore.self),
                service: resolver.resolve(VPNConfigurationService.self),
                settingsController: resolver.resolve(SettingsController.self)
            )
        }
    }
    
    private var settingsController: SettingsController
    private let service: VPNConfigurationService
    @ObservedObject private var store: SettingsStore
    
    init(store: SettingsStore, service: VPNConfigurationService, settingsController: SettingsController) {
        self.store = store
        self.service = service
        self.settingsController = settingsController
        self.store.onLoad {
            self.syncUpdateTimer()
        }
    }
    
    private var logger = Logger(label: "industries.strange.slowdown.CheatController")
    private var timer: Timer?
    
    var cheatExpiry: Date? {
        if store.settings.temporaryRxSpeedExpiry.seconds == 0 {
            return nil
        }
        return store.settings.temporaryRxSpeedExpiry.date
    }
    
    var cheatTimeLeft: TimeInterval {
        return max(cheatExpiry?.timeIntervalSinceNow ?? 0, 0)
    }
    @Published
    public var sampledCheatTimeLeft: TimeInterval = 0
    
    
    var isCheating: Bool {
        return cheatTimeLeft > 0
    }
    
    private func syncUpdateTimer() {
        if !isCheating {
            return
        }
        self.sampleCheatTimeLeft()
        timer = Timer.scheduledTimer(withTimeInterval: cheatTimeLeft.truncatingRemainder(dividingBy: 1), repeats: false) { _ in
            self.startCheatUpdateTimer()
        }
    }
    
    private func startCheatUpdateTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.sampleCheatTimeLeft()
            if !self.isCheating {
                self.timer?.invalidate()
            }
        }
        self.sampleCheatTimeLeft()
    }
    
    
    @MainActor
    private func sampleCheatTimeLeft() {
        self.sampledCheatTimeLeft = self.cheatTimeLeft
    }
    
    func addCheat() async throws {
        let fromNow = TimeInterval(min(60 * 5, self.cheatTimeLeft + 60))
        self.store.setCheatSettings(expiry: Date() + fromNow, speed: Double.infinity)
        self.settingsController.syncSettings()
        syncUpdateTimer()
        
        let _ = try await enableNotifications()
        self.clearNotifications()
        try await self.sendMessage(title: "Cheat ended", body: "", fromNow: fromNow)
    }
    
    func stopCheat() async throws  -> Void {
        self.store.setCheatSettings(expiry: Date(), speed: Double.infinity)
        self.settingsController.syncSettings()
        self.timer?.invalidate()
        clearNotifications()
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
