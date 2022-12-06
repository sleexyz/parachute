//
//  AppView.swift
//  slowdown
//
//  Created by Sean Lee on 4/28/22.
//

import SwiftUI
import NetworkExtension
import Combine

final class AppViewModel: ObservableObject {
    @Published var isStarted = false
    @Published var isEnabled = false
    @Published var debug = false
    @Published var isLoading = false
    @Published var isShowingError = false
    @Published private(set) var errorTitle = ""
    @Published private(set) var errorMessage = ""
    
    let service: VPNConfigurationService
    private let tunnel: NETunnelProviderManager
    
    private var bag = [AnyCancellable]()
    
    init(service: VPNConfigurationService = .shared, tunnel: NETunnelProviderManager) {
        self.service = service
        self.tunnel = tunnel
        self.refreshState()
        
        $isEnabled.sink { [weak self] in
            self?.setEnabled($0)
        }.store(in: &bag)
        
//        $debug.sink { [weak self] in
//            self?.setDebug($0)
//        }.store(in: &bag)
    }
    
    private func refreshState() {
        self.isEnabled = tunnel.isEnabled
        self.isStarted = tunnel.connection.status != .disconnected && tunnel.connection.status != .invalid
    }
    
    private func setEnabled(_ isEnabled: Bool) {
        guard isEnabled != tunnel.isEnabled else { return }
        saveToPreferences()
        refreshState()
    }
    
//    private func setDebug(_ debug: Bool) {
//        guard debug != self?.debug else { return }
//        self.debug = debug
//    }
    
    private func saveToPreferences() {
        isLoading = true
        tunnel.saveToPreferences { [weak self] error in
            guard let self = self else { return }
            self.isLoading = false
            if let error = error {
                self.showError(title: "Failed to update VPN configuration", message: error.localizedDescription)
                self.errorMessage = error.localizedDescription
                return
            }
        }
    }
    
    private func showError(title: String, message: String) {
        self.errorTitle = title
        self.errorMessage = message
        self.isShowingError = true
    }
    
    func startConnection() {
        do {
            try tunnel.connection.startVPNTunnel(options: [
                "debug": NSNumber(booleanLiteral: self.debug)
            ])
            //            refreshState()
            self.isStarted = true
        } catch {
            self.showError(
                title: "Failed to start VPN tunnel",
                message: error.localizedDescription
            )
        }
    }
    func stopConnection() {
        tunnel.connection.stopVPNTunnel()
        self.isStarted = false
        // refreshState()
    }
}

struct AppView: View {
    @ObservedObject var model: AppViewModel
    @EnvironmentObject var store: SettingsStore
    
    @ViewBuilder
    var Button: some View {
        if model.isStarted {
            PrimaryButton(title: "stop", action: model.stopConnection, isLoading: $model.isLoading)
        } else {
            VStack {
                Toggle(isOn: $model.debug, label: { Text("Debug")})
                PrimaryButton(title: "start", action: model.startConnection, isLoading: $model.isLoading)
            }
        }
    }
    var body: some View {
        Form {
            Toggle(isOn: $model.isEnabled, label: { Text("Enabled")})
            Button
        }
        .disabled(model.isLoading)
        .alert(isPresented: $model.isShowingError) {
            Alert(
                title: Text(self.model.errorTitle),
                message: Text(self.model.errorMessage),
                dismissButton: .cancel()
            )
        }
        .navigationBarItems(trailing:
                                Spinner(isAnimating: $model.isLoading, color: .label, style: .medium)
        )
    }
}

//struct AppView_Previews: PreviewProvider {
//    static var previews: some View {
//        AepView()
//    }
//}
