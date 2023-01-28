//
//  AppViewModel.swift
//  slowdown
//
//  Created by Sean Lee on 1/5/23.
//

import Foundation
import SwiftUI
import Combine
import Logging
 
final class AppViewModel: ObservableObject {
    struct Provider: Dep {
        func create(r: Registry) -> AppViewModel {
            return AppViewModel(
                service: r.resolve(VPNConfigurationService.self),
                cheatController: r.resolve(CheatController.self),
                settingsController: r.resolve(SettingsController.self),
                settingsStore: r.resolve(SettingsStore.self)
            )
        }
    }
    
    private var logger: Logger = Logger(label: "industries.strange.slowdown.AppViewModel")
    @Published var currentCarouselIndex: Int = 0
    @Published var isShowingError = false
    @Published private(set) var errorTitle = ""
    @Published private(set) var errorMessage = ""
    
    var logSpeed : Binding<Double> {
        Binding {
            return log(self.store.settings.baseRxSpeedTarget)
        } set: {
            self.store.settings.baseRxSpeedTarget = exp($0)
        }
    }
    
    let service: VPNConfigurationService
    let cheatController: CheatController
    let settingsController: SettingsController
    let store: SettingsStore
    
    
    init(service: VPNConfigurationService, cheatController: CheatController, settingsController: SettingsController, settingsStore: SettingsStore) {
        self.service = service
        self.cheatController = cheatController
        self.settingsController = settingsController
        self.store = settingsStore
        self.store.onLoad {
            self.currentCarouselIndex = self.canonicalCarouselIndex()
            self.logger.info("index: \(self.currentCarouselIndex)")
        }
        logger.info("init appviewmodel")
    }
    
    // Finds the canonical carousel index for the given state
    func canonicalCarouselIndex() -> Int {
        if store.settings.mode == .progressive {
            return 0
        }
        if !cheatController.isCheating {
            return 1
        }
        return 2
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
    
    
    func startCheat() {
        Task {
            do {
                try await self.cheatController.addCheat()
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
                } catch {
                    self.showError(
                        title: "Failed to stop cheat",
                        message: error.localizedDescription
                    )
                }
            }
    }
    
    func saveSettings() {
            Task {
                do {
                    try self.store.save()
                } catch {
                    self.showError(
                        title: "Failed to save settings",
                        message: error.localizedDescription
                    )
                }
            }
    }
    
    
    func showError(title: String, message: String) {
        self.errorTitle = title
        self.errorMessage = message
        self.isShowingError = true
    }
}

