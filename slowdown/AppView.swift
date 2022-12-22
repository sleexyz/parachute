//
//  AppView.swift
//  slowdown
//
//  Created by Sean Lee on 4/28/22.
//

import SwiftUI
import NetworkExtension
import Combine
import func os.os_log
import ProxyService

final class AppViewModel: ObservableObject {
    
    @Published var logSpeed: Double
    
    @Published var debug = false
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
            service.stopConnection()
            return
        }
        
        do {
            try self.service.startConnection(debug: self.debug)
        } catch {
            self.showError(
                title: "Failed to start VPN tunnel",
                message: error.localizedDescription
            )
        }
    }
    
    func resetState() {
        Task {
            do {
                var req = Proxyservice_Request()
                req.resetState = Proxyservice_ResetStateRequest()
                try await service.Rpc(message: req)
            } catch {
                self.showError(
                    title: "Failed to reset points",
                    message: error.localizedDescription
                )
            }
        }
    }
    
    func startCheat() {
        Task {
            do {
                try await self.cheatController.startCheat()
            } catch {
                self.showError(
                    title: "Failed to start cheat",
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

struct CheatTimer: View {
    @ObservedObject var cheatController: CheatController
    @State var cheatTimeLeft: Int
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(cheatController: CheatController = .shared) {
        self.cheatController = cheatController
        self.cheatTimeLeft = cheatController.cheatTimeLeft
    }
    
    
    var body: some View {
        Text("\(self.cheatTimeLeft)").onReceive(timer) { _ in
            self.cheatTimeLeft = max(cheatController.cheatTimeLeft, 0)
        }
    }
}

struct AppView: View {
    @ObservedObject var model: AppViewModel
    @ObservedObject var store: SettingsStore = .shared
    @ObservedObject var service: VPNConfigurationService = .shared
    @ObservedObject var cheatController: CheatController = .shared
    var controller: SettingsController = .shared
    
    

    
    @ViewBuilder
    var cheatLoading : some View {
        if cheatController.isCheating {
            CheatTimer()
        } else {
            EmptyView()
        }
    }
    
    var body: some View {
        Form {
            if !service.isConnected {
                PrimaryButton(title: "start", action: model.toggleConnection, isLoading: service.isTransitioning)
                Spacer()
                Toggle(isOn: $model.debug, label: { Text("Debug")})
                    .disabled(service.isTransitioning)
            } else {
                PrimaryButton(title: "stop", action: model.toggleConnection, isLoading: service.isTransitioning)
                Spacer()
                VStack {
                    Slider(
                        value: $model.logSpeed,
                        in: (11...16),
                        onEditingChanged: { editing in
                            if !editing {
                                controller.syncSettings()
                            }
                        }
                    )
                    Text("\(Int(store.settings.baseRxSpeedTarget))")
                }
                Spacer()
                Toggle(isOn: $store.settings.useExponentialDecay, label: { Text("Use Exponential Decay")}).onChange(of: store.settings.useExponentialDecay) { value in
                    controller.syncSettings()
                }
                Spacer()
                PrimaryButton(title: "reset state", action: model.resetState, isLoading: false)
                Spacer()
                PrimaryButton(title: "cheat", action: model.startCheat, isLoading: cheatController.isCheating, loadingMessage: cheatLoading).disabled(cheatController.isCheating)
            }
        }
        .disabled(service.isTransitioning)
        .alert(isPresented: $model.isShowingError) {
            Alert(
                title: Text(self.model.errorTitle),
                message: Text(self.model.errorMessage),
                dismissButton: .cancel()
            )
        }
        .navigationBarItems(trailing:
                                Spinner(isAnimating: service.isTransitioning, color: .label, style: .medium)
        )
    }
}

//struct AppView_Previews: PreviewProvider {
//    static var previews: some View {
//        AppView(model: )
//    }
//}
