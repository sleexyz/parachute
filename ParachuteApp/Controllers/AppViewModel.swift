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
import DI
import Controllers
 
// TODO: deprecate. Have a Error handler.
final class AppViewModel: ObservableObject {
    struct Provider: Dep {
        func create(r: Registry) -> AppViewModel {
            return AppViewModel(
                service: r.resolve(VPNConfigurationService.self),
                settingsController: r.resolve(SettingsController.self),
                settingsStore: r.resolve(SettingsStore.self)
            )
        }
    }
    
    private var logger: Logger = Logger(label: "industries.strange.slowdown.AppViewModel")
    @Published var isShowingError = false
    @Published private(set) var errorTitle = ""
    @Published private(set) var errorMessage = ""
    
    var logSpeed : Binding<Double> {
        Binding {
            return log(self.settingsStore.activePresetBinding.wrappedValue.baseRxSpeedTarget)
        } set: {
            self.settingsStore.activePresetBinding.wrappedValue.baseRxSpeedTarget = exp($0)
        }
    }
    
    let service: VPNConfigurationService
    let settingsController: SettingsController
    let settingsStore: SettingsStore
    
    
    init(service: VPNConfigurationService, settingsController: SettingsController, settingsStore: SettingsStore) {
        self.service = service
        self.settingsController = settingsController
        self.settingsStore = settingsStore
        logger.info("init appviewmodel")
    }
    
    func saveSettings() {
            Task {
                do {
                    try self.settingsStore.save()
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

