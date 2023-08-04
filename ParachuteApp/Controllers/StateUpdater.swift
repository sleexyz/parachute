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

let INITIAL_FETCH_DELAY_SECS: Int = 5
let LOOP_FETCH_DELAY_SECS: Int = 5

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
            $isVisible.withPrevious(),
            vpnConfigurationService.$status
        )
        .sink { [weak self] (isVisibleTuple, status) in
            let isVisiblePrevious = isVisibleTuple.0 ?? false
            let isVisible = isVisibleTuple.1
            if isVisible  && !isVisiblePrevious && status == .connected {
                self?.startSubscription()
            }
            else if !isVisible && isVisiblePrevious {
                self?.cancelSubscription()
            }
        }.store(in: &bag)
    }
    
    @MainActor
    public func setVisible(_ value: Bool) {
        isVisible = value
    }
    
    private func startSubscription() {
        Task {
            cancelSubscription()
            guard let connectedDate = self.vpnConfigurationService.connectedDate else {
                self.startSubscriptionLoop()
                return
            }
            let timeSinceConnected = Date().timeIntervalSince(connectedDate)
            let sleepTime = max(Double(INITIAL_FETCH_DELAY_SECS) - timeSinceConnected, 0)
            try await Task.sleep(nanoseconds: UInt64(sleepTime * Double(NSEC_PER_SEC)))
            self.startSubscriptionLoop()
        }
    }
    
    private func startSubscriptionLoop() {
        CancellableLoop {
            self.stateController.fetchState()
            try! await Task.sleep(nanoseconds: UInt64(LOOP_FETCH_DELAY_SECS) * NSEC_PER_SEC)
        }.store(in: &loopBag)
    }
    
    private func cancelSubscription() {
        for x in loopBag {
//            logger.info("cancelling \(x)")
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
