import SwiftUI
import Controllers
import AppHelpers


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
                    
                    if #available(iOS 16.2, *) {
                        ActivitiesHelper.shared.start()
                    } else {
                        // Fallback on earlier versions
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
