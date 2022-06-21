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
    @Published var isLoading = false
    @Published var isShowingError = false
    @Published private(set) var errorTitle = ""
    @Published private(set) var errorMessage = ""
    
    private let service: VPNConfigurationService
    private let tunnel: NETunnelProviderManager
    
    private var bag = [AnyCancellable]()
    
    init(service: VPNConfigurationService = .shared, tunnel: NETunnelProviderManager) {
        self.service = service
        self.tunnel = tunnel
        self.refresh()
        
        $isEnabled.sink { [weak self] in
            self?.setEnabled($0)
        }.store(in: &bag)
    }
    
    private func refresh() {
        self.isEnabled = tunnel.isEnabled
        self.isStarted = tunnel.connection.status != .disconnected && tunnel.connection.status != .invalid
    }
    
    private func setEnabled(_ isEnabled: Bool) {
        guard isEnabled != tunnel.isEnabled else { return }
        tunnel.isEnabled = isEnabled;
        saveToPreferences()
    }
    
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
            try tunnel.connection.startVPNTunnel()
        } catch {
            self.showError(
                title: "Failed to start VPN tunnel",
                message: error.localizedDescription
            )
        }
    }
    func stopConnection() {
        tunnel.connection.stopVPNTunnel()
    }
}

struct AppView: View {
    @ObservedObject var model: AppViewModel
    var body: some View {
        Form {
            Toggle(isOn: $model.isEnabled, label: { Text("Enabled")})
            PrimaryButton(title: "start", action: model.startConnection, isLoading: $model.isLoading)
            PrimaryButton(title: "stop", action: model.stopConnection, isLoading: $model.isLoading)
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
//        AppView()
//    }
//}
