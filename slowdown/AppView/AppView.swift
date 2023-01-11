//
//  AppView.swift
//  slowdown
//
//  Created by Sean Lee on 4/28/22.
//

import SwiftUI

struct AppView: View {
    @EnvironmentObject var model: AppViewModel
    @ObservedObject var store: SettingsStore = .shared
    @ObservedObject var service: VPNConfigurationService = .shared
    @ObservedObject var cheatController: CheatController = .shared
    var controller: SettingsController = .shared
    
    init(store: SettingsStore = .shared, service: VPNConfigurationService = .shared, cheatController: CheatController = .shared, controller: SettingsController = .shared) {
        self.store = store
        self.service = service
        self.cheatController = cheatController
        self.controller = controller
        self.service = service
    }
    
    var body: some View {
        VStack{
            if !service.isConnected {
                VStack {
                    Spacer()
                    PrimaryButton(title: "Start", action: model.toggleConnection, isLoading: service.isTransitioning)
                    Spacer()
                    Toggle(isOn: $store.settings.debug, label: { Text("Debug")})
                        .disabled(service.isTransitioning)
                        .onChange(of: store.settings.debug) { _ in
                            model.saveSettings()
                        }
                }.padding()
            } else {
                VStack {
                    PrimaryButton(title: "Stop", action: model.toggleConnection, isLoading: service.isTransitioning)
                }.padding()
                Spacer()
                ProgressiveModeView()
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

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        let service = MockVPNConfigurationService(store: .shared)
        service.setIsConnected(value: true)
        return AppView(service: service).environmentObject(AppViewModel())
    }
}

struct AppViewOff_Previews: PreviewProvider {
    static var previews: some View {
        let service = MockVPNConfigurationService(store: .shared)
        service.setIsConnected(value: false)
        return AppView(service: service).environmentObject(AppViewModel())
    }
}
