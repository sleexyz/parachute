//
//  SetupView.swift
//  slowdown
//
//  Created by Sean Lee on 12/27/22.
//

import Foundation
import SwiftUI
import Controllers

struct SetupView: View {
    @EnvironmentObject private var service: NEConfigurationService

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
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        self.isLoading = true
        Task { @MainActor in
            do {
                try await service.install()
            } catch let error {
                self.errorMessage = error.localizedDescription
                self.isShowingError = true
            }
            self.isLoading = false
        }
    }
}
