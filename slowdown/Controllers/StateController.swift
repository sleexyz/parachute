//
//  StateController.swift
//  slowdown
//
//  Created by Sean Lee on 1/6/23.
//

import Foundation
import ProxyService
import Logging
import SwiftUI
import Combine

class StateController: ObservableObject  {
    struct Provider: Dep {
        func create(r: Registry) -> StateController  {
            return StateController(
                settings: r.resolve(SettingsStore.self),
                service: r.resolve(VPNConfigurationService.self)
            )
        }
    }
    
    private let logger: Logger = Logger(label: "industries.strange.slowdown.StateController")
    @Published var state: Proxyservice_GetStateResponse = Proxyservice_GetStateResponse()
    
    let settings: SettingsStore
    let service: VPNConfigurationService
    
    var bag = Set<AnyCancellable>()
    
    init(settings: SettingsStore, service: VPNConfigurationService) {
        self.settings = settings
        self.service = service
        self.settings.$settings.sink { _ in
            self.objectWillChange.send()
        }.store(in: &bag)
    }
    
    var isSlowing: Bool {
        let usagePoints = state.usagePoints
        let usageMaxHp = settings.activePreset.usageMaxHp
        let damageRatio = usagePoints / usageMaxHp
        return damageRatio > 0.5
    }
    
    var damageRatio: Double {
        return state.usagePoints / settings.activePreset.usageMaxHp
    }
    
    var healTimeLeft: Double {
        return state.usagePoints / settings.activePreset.usageHealRate
    }
    
    var hpRatio: Double {
        return 1 - damageRatio
    }
    
    var scrollTimeLeft: Double {
        return max(settings.activePreset.usageMaxHp / 2 - state.usagePoints, 0)
    }
    
    var hpColor: Color {
        if hpRatio < 0.5 {
            return .yellow
        }
        return .green
    }
    
    @MainActor
    internal func setState(value: Proxyservice_GetStateResponse) {
        state = value
    }
    
    @MainActor
    private func setUsagePoints(value: Double) {
        state.usagePoints = value
    }
    
    func heal() {
        Task {
            do {
                let value = try await service.Heal()
                await self.setUsagePoints(value: value.usagePoints)
//                logger.info("state: \(state.debugDescription)")
            } catch let error {
                logger.info("error: \(error.localizedDescription)")
                
            }
        }
    }
    
    func fetchState() {
        Task {
            do {
                let value = try await service.GetState()
                await self.setState(value: value)
//                logger.info("state: \(state.debugDescription)")
            } catch let error {
                logger.info("error: \(error.localizedDescription)")
                
            }
        }
    }
}
