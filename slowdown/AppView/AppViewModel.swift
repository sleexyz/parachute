//
//  AppViewModel.swift
//  slowdown
//
//  Created by Sean Lee on 1/5/23.
//

import Foundation
import SwiftUI
import Combine
 
final class AppViewModel: ObservableObject {
    @Published var currentIndex: Int = 0
    @Published var logSpeed: Double
    @Published var isShowingError = false
    @Published private(set) var errorTitle = ""
    @Published private(set) var errorMessage = ""
    private var bag = [AnyCancellable]()
    let service: VPNConfigurationService
    let cheatController: CheatController
    let settingsController: SettingsController
    let store: SettingsStore
    
    
    init(service: VPNConfigurationService = .shared, cheatController: CheatController = .shared, settingsController: SettingsController = .shared, settingsStore: SettingsStore = .shared) {
        self.service = service
        self.cheatController = cheatController
        self.settingsController = settingsController
        self.store = settingsStore
        logSpeed = log(settingsStore.settings.baseRxSpeedTarget)
        $logSpeed.sink {
            settingsStore.settings.baseRxSpeedTarget = exp($0)
        }.store(in: &bag)
    }
    
    func toggleConnection() {
        if service.isConnected {
            Task {
                do {
                    try await service.stopConnection()
                } catch {
                    self.showError(
                        title: "Failed to stop VPN tunnel",
                        message: error.localizedDescription
                    )
                }
            }
            return
        }
        
        Task {
            do {
                try await self.service.startConnection()
            } catch {
                self.showError(
                    title: "Failed to start VPN tunnel",
                    message: error.localizedDescription
                )
            }
        }
    }
    
    @MainActor
    func setCurrentIndex(value: Int) {
        self.currentIndex = value
    }
    
    func startCheat() {
        Task {
            do {
                try await self.cheatController.addCheat()
//                await setCurrentIndex(value: 1)
            } catch {
                self.showError(
                    title: "Failed to start cheat",
                    message: error.localizedDescription
                )
            }
        }
    }
    
    func stopCheat() {
            Task {
                do {
                    try await self.cheatController.stopCheat()
//                    await setCurrentIndex(value: 0)
                } catch {
                    self.showError(
                        title: "Failed to stop cheat",
                        message: error.localizedDescription
                    )
                }
            }
    }
    
    
    private func showError(title: String, message: String) {
        self.errorTitle = title
        self.errorMessage = message
        self.isShowingError = true
    }
}

