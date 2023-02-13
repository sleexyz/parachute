//
//  StateUpdater.swift
//  slowdown
//
//  Created by Sean Lee on 2/11/23.
//

import Foundation
import Combine
import Logging
import SwiftUI

class StateUpdater: ObservableObject {
    struct Provider: Dep {
        func create(r: Registry) -> StateUpdater {
            return StateUpdater(
                stateController: r.resolve(StateController.self),
                vpnConfigurationService: r.resolve(VPNConfigurationService.self)
            )
        }
    }
    private var logger = Logger.init(label: "industries.strange.slowdown.StateUpdater")
    private var stateController: StateController
    private var vpnConfigurationService: VPNConfigurationService
    
    // Whether a state-derived view is visible
    @Published var isVisible: Bool = false
    
    private var bag = Set<AnyCancellable>()
    private var loopBag = Set<AnyCancellable>()
    
    init(stateController: StateController, vpnConfigurationService: VPNConfigurationService) {
        self.stateController = stateController
        self.vpnConfigurationService = vpnConfigurationService
        
        Publishers.CombineLatest(
            $isVisible,
            vpnConfigurationService.$status.debounce(for: .seconds(5), scheduler: DispatchQueue.main)
        )
            .sink { [weak self] (isVisible, status) in
                if isVisible && status == .connected {
                    self?.startSubscription()
                } else {
                    self?.cancelSubscription()
                }
            }.store(in: &bag)
    }
    
    @MainActor
    public func setVisible(_ value: Bool) {
        isVisible = value
    }
    
    private func startSubscription() {
        cancelSubscription()
        CancellableLoop {
            self.stateController.fetchState()
            try! await Task.sleep(nanoseconds: 5_000_000_000)
        }.store(in: &loopBag)
    }
    
    private func cancelSubscription() {
        for x in loopBag {
            x.cancel()
        }
        loopBag.removeAll()
    }
    
    struct IsVisibleUpdater: ViewModifier {
        @Environment(\.scenePhase) var scenePhase
        @EnvironmentObject private var stateUpdater: StateUpdater
        
        func body(content: Content) -> some View {
            content
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        stateUpdater.setVisible(true)
                    } else {
                        stateUpdater.setVisible(false)
                    }
                }
                .onAppear {
                    stateUpdater.setVisible(true)
                }
                .onDisappear {
                    stateUpdater.setVisible(false)
                }
        }
    }
}

class CancellableLoop: Cancellable {
    var _cancel: Bool = false
    let perform: () async -> ()
    
    init(_ perform: @escaping () async -> ()) {
        self.perform = perform
        connect()
    }
    
    func connect() {
        Task {
            while true {
                if _cancel {
                    return
                }
                await perform()
            }
        }
    }
    
    func cancel() {
        _cancel = true
    }
    
}
