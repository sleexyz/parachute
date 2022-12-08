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
    let cheatController: CheatController = .shared
    
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
    @EnvironmentObject var store: SettingsStore
    @ObservedObject var service: VPNConfigurationService = .shared
    @ObservedObject var cheatController: CheatController = .shared
    
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
