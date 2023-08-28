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
//                        guard let profileManager = ProfileManager.shared else  {
//                            throw MyIntentError.message("ProfileManager not initialized")
//                        }
                        try await profileManager.loadPreset(
                            preset: .focus,
                            overlay: .quickBreak
                        )
                        if #available(iOS 16.2, *) {
                            await ActivitiesHelper.shared.update(settings: SettingsStore.shared.settings)
                        }
                        ScrollSessionViewController.shared.setClosed()
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
