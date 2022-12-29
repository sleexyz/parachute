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
import Intents

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
                try await self.service.startConnection(debug: self.debug)
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
    
    func doAsync(fn: @escaping () async throws -> Void) -> () -> Void{
        return {
            Task {
                do {
                    try await fn()
                } catch {
                    self.showError(
                        title: "Unexpected error",
                        message: error.localizedDescription
                    )
                }
            }
        }
    }
    
    
    private func showError(title: String, message: String) {
        self.errorTitle = title
        self.errorMessage = message
        self.isShowingError = true
    }
}

struct AppView: View {
    @ObservedObject var model: AppViewModel
    @ObservedObject var store: SettingsStore
    @ObservedObject var service: VPNConfigurationService
    @ObservedObject var cheatController: CheatController
    var controller: SettingsController = .shared
    
    init(model: AppViewModel, store: SettingsStore = .shared, service: VPNConfigurationService = .shared, cheatController: CheatController = .shared, controller: SettingsController = .shared) {
        self.model = model
        self.store = store
        self.service = service
        self.cheatController = cheatController
        self.controller = controller
    }
    
    
    var cheatButton : some View {
        var icon = AnyView(Text("😎"))
        var title = ""
        if cheatController.isCheating  {
            icon = AnyView(Button(action: model.startCheat) {
                Text("🤤")
            })
            let t = Int(cheatController.sampledCheatTimeLeft + 1)
            let min = t / 60
            let sec = t % 60
            if min > 0 {
                title += "\(min)m"
            }
            if sec > 0 {
                if title != "" {
                    title += " "
                }
                title += "\(sec)s"
            }
        }
        return VStack {
            Spacer()
            ZStack(alignment: .top) {
                icon
                    .font(.system(size: 144))
                    .padding()
                    .frame(maxWidth: .infinity)
                if title != "" {
                    Text(title).padding().offset(x: 0, y: 200)
                }
            }
            Spacer()
            HStack{
                if cheatController.isCheating {
                    Button(action: model.doAsync(fn: cheatController.stopCheat)) {
                        Text("😎")
                            .font(.system(size: 32))
                    }
                } else {
                    Button(action: model.startCheat) {
                        Text("🤤")
                            .font(.system(size: 32))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            Spacer()
        }
    }
    
    var body: some View {
        VStack{
            if !service.isConnected {
                PrimaryButton(title: "Start", action: model.toggleConnection, isLoading: service.isTransitioning)
                Spacer()
                Toggle(isOn: $model.debug, label: { Text("Debug")})
                    .disabled(service.isTransitioning)
            } else {
                PrimaryButton(title: "Stop", action: model.toggleConnection, isLoading: service.isTransitioning)
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
                cheatButton
                Spacer()
            }
        }
        .padding()
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

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        let appModel = AppViewModel()
        let service = MockVPNConfigurationService(store: .shared)
        service.setIsConnected(value: true)
        return  AppView(model: appModel, service: service)
    }
}
