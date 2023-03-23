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
    
    var showTransitioning: Bool {
        return service.isTransitioning
    }
    
    var body: some View {
        VStack{
            if !service.isConnected {
                DisconnectedView()
            } else {
                ConnectedView()
                .modifier(StateUpdater.IsVisibleUpdater())
                    .provideDeps([
                        ProfileManager.Provider(),
                        StateUpdater.Provider(),
                        StateController.Provider()
                    ])
            }
        }
        .disabled(showTransitioning)
        .alert(isPresented: $model.isShowingError) {
            Alert(
                title: Text(self.model.errorTitle),
                message: Text(self.model.errorMessage),
                dismissButton: .cancel()
            )
        }
        .navigationBarItems(trailing:
                                Spinner(isAnimating: showTransitioning, color: .label, style: .medium)
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
