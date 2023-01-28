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


class StateController: ObservableObject  {
    struct Provider: Dep {
        func create(resolver: Resolver) -> StateController  {
            return StateController(
                settings: resolver.resolve(SettingsStore.self),
                service: resolver.resolve(VPNConfigurationService.self)
            )
        }
    }
    
    private let logger: Logger = Logger(label: "industries.strange.slowdown.StateController")
    @Published var state: Proxyservice_GetStateResponse = Proxyservice_GetStateResponse()
    
    let settings: SettingsStore
    let service: VPNConfigurationService
    
    init(settings: SettingsStore, service: VPNConfigurationService) {
        self.settings = settings
        self.service = service
    }
    
    var isSlowing: Bool {
        let usagePoints = state.usagePoints
        let usageMaxHp = settings.settings.usageMaxHp
        let damageRatio = usagePoints / usageMaxHp
        return damageRatio > 0.5
    }
    
    var damageRatio: Double {
        return state.usagePoints / settings.settings.usageMaxHp
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
                logger.info("state: \(state.debugDescription)")
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
                logger.info("state: \(state.debugDescription)")
            } catch let error {
                logger.info("error: \(error.localizedDescription)")
                
            }
        }
    }
}
