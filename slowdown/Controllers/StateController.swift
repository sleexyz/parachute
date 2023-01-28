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
    @State var timer = StateSubscriber.initializeTimer()
    
    static func initializeTimer() -> Publishers.Autoconnect<Timer.TimerPublisher> {
         return Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    }

    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    startSubscription()
                } else {
                    timer.upstream.connect().cancel()
                }
            }
            .onAppear {
                startSubscription()
            }
            .onReceive(timer) {_ in
                self.stateController.fetchState()
            }
    }
    
    func startSubscription() {
        self.stateController.fetchState()
        timer = StateSubscriber.initializeTimer()
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
