//
//  SetupView.swift
//  slowdown
//
//  Created by Sean Lee on 12/27/22.
//

import Foundation
import SwiftUI
import Controllers

public struct SetupView: View {
    @EnvironmentObject private var service: NEConfigurationService
    @EnvironmentObject var settingsStore: SettingsStore

    @State private var isLoading = false
    @State private var isShowingError = false
    @State private var errorMessage = ""
    
    
    public init() {}

    public var body: some View {
        VStack(alignment: .leading) {
            Text([
                "Faucet protects your attention by delaying content from loading.",
            ].joined(separator: "\n\n"))
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .multilineTextAlignment(.leading)
                .padding()

            Text([
                "This is done by intercepting network requests via a Content Filter.",
            ].joined(separator: "\n\n"))
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .multilineTextAlignment(.leading)
                .padding()

            buttonInstall
                .padding()
                .padding(.vertical, 48)

            Text([
                "To protect your privacy, no data ever leaves the Content Filter.",
            ].joined(separator: "\n\n"))
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .multilineTextAlignment(.leading)
                .padding()
        }.padding()
    }

    private var buttonInstall: some View {
        Button(action: {
            installProfile()
        }, label: {
            Text("Install Content Filter")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.parachuteOrange)
                .cornerRadius(8)
        })

        .alert(isPresented: $isShowingError) {
            Alert(
                title: Text("Failed to install content filter."),
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
                try await service.install(settings: settingsStore.settings)
            } catch let error {
                self.errorMessage = error.localizedDescription
                self.isShowingError = true
            }
            self.isLoading = false
        }
    }
}
