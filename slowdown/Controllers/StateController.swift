//
//  StateController.swift
//  slowdown
//
//  Created by Sean Lee on 1/6/23.
//

import Foundation
import ProxyService
import Logging

class StateController: ObservableObject  {
    private let logger: Logger = Logger(label: "industries.strange.slowdown.StateController")
    @Published var state: Proxyservice_GetStateResponse = Proxyservice_GetStateResponse()
    private let service: VPNConfigurationService = .shared
    static let shared = StateController()
    
    
    @MainActor
    private func setState(value: Proxyservice_GetStateResponse) {
        state = value
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
