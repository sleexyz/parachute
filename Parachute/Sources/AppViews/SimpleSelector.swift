import SwiftUI
import Controllers
import AppHelpers
import Models
import Controllers
import OSLog

public struct SimpleSelector: View {
    @EnvironmentObject private var profileManager: ProfileManager
    @EnvironmentObject private var settingsStore: SettingsStore

    var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SimpleSelector")

    public init() {}

    public var body: some View {
        VStack {
            Button(action: {
                Task { @MainActor in
                    // var overlay: Preset = .quickBreak
                    // overlay.overlayDurationSecs = Double(settingsStore.settings.quickSessionSecs)

                    // try await profileManager.loadPreset(
                    //     preset: .focus,
                    //     overlay: overlay
                    // )
                    // if #available(iOS 16.2, *) {
                    //     await ActivitiesHelper.shared.update(settings: SettingsStore.shared.settings)
                    // }
                    // await ScrollSessionViewController.shared.setClosed()
                    logger.info("ScrollSessionIntent.perform")
                    await ScrollSessionViewController.shared.setOpen()
                }
            }) {
                Text("Scroll")
                    .font(.title)
                    .padding()
            } 
            .tint(.parachuteOrange)
            .buttonBorderShape(.capsule)
            .buttonStyle(.bordered)
        }
    }
}
