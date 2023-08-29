import SwiftUI
import Controllers
import AppHelpers
import Models

public struct SimpleSelector: View {
    @EnvironmentObject private var profileManager: ProfileManager
    @EnvironmentObject private var settingsStore: SettingsStore

    public init() {}

    public var body: some View {
        VStack {
            if profileManager.activePreset.id == "focus" {
                Button(action: {
                    Task { @MainActor in
                        var overlay: Preset = .quickBreak
                        overlay.overlayDurationSecs = Double(settingsStore.settings.quickSessionSecs)

                        try await profileManager.loadPreset(
                            preset: .focus,
                            overlay: overlay
                        )
                        if #available(iOS 16.2, *) {
                            await ActivitiesHelper.shared.update(settings: SettingsStore.shared.settings)
                        }
                        await ScrollSessionViewController.shared.setClosed()
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
