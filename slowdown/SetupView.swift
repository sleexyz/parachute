//
//  SetupView.swift
//  slowdown
//
//  Created by Sean Lee on 12/27/22.
//

import Foundation
import SwiftUI

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
