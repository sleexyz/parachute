import SwiftUI
import Controllers


public struct SimpleSelector: View {
    @EnvironmentObject private var profileManager: ProfileManager
    @EnvironmentObject private var settingsStore: SettingsStore

    public init() {}

    public var body: some View {
        VStack {
            if profileManager.activePreset.id == "focus" {
                Button(action: {
                    Task { @MainActor in
                        try await profileManager.loadPreset(
                            preset: ProfileManager.presetDefaults["focus"]!,
                            overlay: ProfileManager.presetDefaults["relax"]!
                        )
                    }
                }) {
                    Text("Start scroll break 🍪")
                } 
            } else {
                Text("Scroll break in progress...")
            }
        }
    }
}
