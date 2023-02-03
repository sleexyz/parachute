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

struct StateSubscriber: ViewModifier {
    @Environment(\.scenePhase) var scenePhase

    @EnvironmentObject var stateController: StateController
    @State var cancel: Bool = false
    
    @MainActor
    func setCancel(value: Bool) {
        cancel = value
    }

    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    startSubscription()
                } else {
                    setCancel(value: false)
                }
            }
            .onAppear {
                    startSubscription()
            }
            .onDisappear {
                setCancel(value: true)
            }
    }
    
    func startSubscription() {
        Task {
            setCancel(value:false)
            await loop()
        }
    }
    func loop() async {
        if cancel {
            return
        }
        self.stateController.fetchState()
        try! await Task.sleep(nanoseconds: 1_000_000_000)
        return await loop()
    }
}

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
