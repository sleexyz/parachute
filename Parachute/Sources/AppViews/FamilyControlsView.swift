import SwiftUI
import FamilyControls

public struct FamilyControlsView: View {
    // @EnvironmentObject private var service: NEConfigurationService
    // @EnvironmentObject var settingsStore: SettingsStore

    let center = AuthorizationCenter.shared

    @State private var isLoading = false
    @State private var isShowingError = false
    @State private var errorMessage = ""
    
    public init() {}

    public var body: some View {
        VStack(alignment: .leading) {
            Text("Parachute protects your attention by **delaying social media feeds from loading.**")
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .multilineTextAlignment(.leading)
                .padding()

            Text([
                "To this, Parachute needs to Screen Time access on your phone:",
            ].joined(separator: "\n\n"))
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .multilineTextAlignment(.leading)
                .padding()

            buttonInstall
                .padding()
                .padding(.vertical, 36)
        }.padding()
    }

    private var buttonInstall: some View {
        Button(action: {
            installFamilyControls()
        }, label: {
            Text("Enable Screen Time Access")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.parachuteOrange.opacity(0.9))
                .cornerRadius(8)
        })
        .alert(isPresented: $isShowingError) {
            Alert(
                title: Text("Failed to enable Screen Time access"),
                message: Text(errorMessage),
                dismissButton: .cancel()
            )
        }
    }

    private func installFamilyControls() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        self.isLoading = true
        Task { @MainActor in
            do {
                try await center.requestAuthorization(for: .individual)
                // try await service.install(settings: settingsStore.settings)
            } catch let error {
                self.errorMessage = error.localizedDescription
                self.isShowingError = true
            }
            self.isLoading = false
        }
    }
}
