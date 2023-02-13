//
//  AppView.swift
//  slowdown
//
//  Created by Sean Lee on 4/28/22.
//

import SwiftUI

struct AppView: View {
    @EnvironmentObject var model: AppViewModel
    @EnvironmentObject var store: SettingsStore
    @EnvironmentObject var service: VPNConfigurationService
    @EnvironmentObject var cheatController: CheatController
    @EnvironmentObject var controller: SettingsController
    
    
    var body: some View {
        let _  = Self._printChanges()
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
                    VStack {
                        PrimaryButton(title: "Stop", action: model.toggleConnection, isLoading: service.isTransitioning)
                    }.padding()
                    Spacer()
                    ProgressiveModeView()
                    Spacer()
                }
                .modifier(StateUpdater.IsVisibleUpdater())
                    .provideDeps([
                        StateUpdater.Provider(),
                        StateController.Provider()
                    ])
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
        AppView()
            .consumeDep(MockVPNConfigurationService.self) { value in
                value.setIsConnected(value: true)
            }
            .provideDeps(previewDeps)
    }
}

struct AppViewOff_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
            .consumeDep(MockVPNConfigurationService.self) { value in
                value.setIsConnected(value: false)
            }
            .provideDeps(previewDeps)
    }
}
