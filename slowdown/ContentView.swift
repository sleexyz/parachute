//
//  ContentView.swift
//  slowdown
//
//  Created by Sean Lee on 1/30/22.
//

import SwiftUI

import Foundation


struct ContentView: View {
    @ObservedObject var service: VPNConfigurationService = .shared
    var body: some View {
        if service.isInitializing {
            return AnyView(SplashView())
        }
        
        if service.hasManager {
            let model = AppViewModel()
            return AnyView(AppView(model:model))
        } else {
            return AnyView(SetupView())
        }
    }
}


struct SetupView: View {
    let service: VPNConfigurationService = .shared

    @State private var isLoading = false
    @State private var isShowingError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            VStack {
                buttonInstall
            }.padding()
        }
    }

    private var buttonInstall: some View {
        PrimaryButton(
            title: "Install VPN Profile",
            action: self.installProfile,
            isLoading: self.isLoading
        ).alert(isPresented: $isShowingError) {
            Alert(
                title: Text("Failed to install a profile"),
                message: Text(errorMessage),
                dismissButton: .cancel()
            )
        }
    }

    private func installProfile() {
        self.isLoading = true

        service.installProfile { result in
            self.isLoading = false
            switch result {
            case .success:
                break // Do nothing, router will show what's next
            case let .failure(error):
                self.errorMessage = error.localizedDescription
                self.isShowingError = true
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
