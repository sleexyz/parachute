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
    
    @Published var debug = false
    @Published var isShowingError = false
    @Published private(set) var errorTitle = ""
    @Published private(set) var errorMessage = ""
    private var bag = [AnyCancellable]()
    let service: VPNConfigurationService = .shared
    
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
    
    private func showError(title: String, message: String) {
        self.errorTitle = title
        self.errorMessage = message
        self.isShowingError = true
    }
}

struct AppView: View {
    @ObservedObject var model: AppViewModel
    @EnvironmentObject var store: SettingsStore
    @ObservedObject var service: VPNConfigurationService = .shared
    
    var body: some View {
        Form {
            PrimaryButton(title: service.isConnected ? "stop" : "start", action: model.toggleConnection, isLoading: service.isTransitioning)
            Toggle(isOn: $model.debug, label: { Text("Debug")})
                .disabled(service.isConnected || service.isTransitioning)
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
