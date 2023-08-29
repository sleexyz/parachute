import SwiftUI
import Controllers
import AppHelpers
import Models
import Controllers
import OSLog

public struct SimpleSelector: View {
    @EnvironmentObject private var profileManager: ProfileManager
    @EnvironmentObject private var settingsStore: SettingsStore
    @EnvironmentObject private var connectedViewController: ConnectedViewController

    var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SimpleSelector")

    public init() {}

    public var body: some View {
        VStack {
            Button(action: {
                Task { @MainActor in
                    connectedViewController.set(state: .scrollSession)
                }
            }) {
                Text("Scroll")
                    .font(.title)
                    .padding()
            } 
            .tint(.parachuteOrange)
            .buttonBorderShape(.capsule)
            .buttonStyle(.borderedProminent)
        }
    }
}
