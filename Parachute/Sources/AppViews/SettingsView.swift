import CommonViews
import Controllers
import ProxyService
import SwiftUI

struct SettingsView: View {
    @Binding var isPresented: Bool
    @Binding var isAdvancedPresented: Bool
    @Binding var isAppsPresented: Bool
    @State private var isFeedbackOpen = false

    var body: some View {
        // Closing pane should switch to main view
        Pane(isPresented: $isPresented, bg: .background) {
            // TODO: put sections behind rows.
            SettingsSyncer {
                VStack(alignment: .leading) {
                    HStack {
                        DisableButton(isSettingsPresented: $isPresented)
                        Spacer()

                        FeedbackButton()
                            .padding()
                    }
                    .padding(.vertical, 20)


                    TimePicker()
                    .padding(.vertical, 20)

                    SettingsHeader(label: "Apps", page: .apps)
                    .padding(.vertical, 20)

                    SettingsHeader(label: "Advanced", page: .advanced)
                        .padding(.vertical, 20)

                    Spacer()
                }
                .font(.system(size: 16, weight: .regular, design: .rounded))
            }
        }
        .blur(radius: isAdvancedPresented ? 8 : 0)
        .scaleEffect(isAdvancedPresented ? 0.98 : 1) // Add scale effect when settings page is open
        .animation(.easeInOut(duration: 0.2), value: isAdvancedPresented) // Add animation to the blur effect

        Pane(isPresented: $isAppsPresented, bg: .background) {
            AppsPicker()
        }

        // Closing pane should switch to settings view
        Pane(isPresented: $isAdvancedPresented, bg: .background) {
            AdvancedSettingsContent()
        }
    }
}

struct ConnectedSettingsView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var connectedViewController: ConnectedViewController

    var body: some View {
        SettingsView(
            isPresented: $isPresented,
            isAdvancedPresented: connectedViewController.isAdvancedSettingsPresented,
            isAppsPresented: connectedViewController.isAppsSettingsPresented
        )
    }
}

struct SettingsSyncer<Content: View>: View {
    @EnvironmentObject var settingsController: SettingsController
    @EnvironmentObject var settingsStore: SettingsStore

    @State private var isSyncing = false

    let content: () -> Content

    var body: some View {
        content()
            .onChange(of: settingsStore.settings) { _ in
                Task { @MainActor in
                    await syncSettings()
                }
            }
    }

    func syncSettings() async {
        guard !isSyncing else {
            return
        }
        isSyncing = true
        do {
            try await settingsController.syncSettings(reason: "settings syncer")
        } catch {
            print("Error syncing settings: \(error)")
        }
        isSyncing = false
    }
}

struct SettingsHeader: View {
    @EnvironmentObject var settingsController: SettingsController
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var connectedViewController: ConnectedViewController

    var label: String
    var page: SettingsPage

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text(label)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.trailing, 20)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            connectedViewController.setSettingsPage(page: page)
        }
    }
}

struct DisableButton: View {
    @Binding var isSettingsPresented: Bool
    @EnvironmentObject var vpnLifecycleManager: VPNLifecycleManager

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            vpnLifecycleManager.disable(until: Date(timeIntervalSinceNow: 60 * 60))
            // vpnLifecycleManager.pauseConnection(until: Date(timeIntervalSinceNow: 60 * 60))
            isSettingsPresented = false
        }, label: {
            Text("Disable for 1 hour")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                // .multilineTextAlignment(.leading)
                .padding()
        })
        .buttonStyle(.bordered)
        .padding()
        .tint(.white.opacity(0.5))
    }
}

struct TimePicker: View {
    @EnvironmentObject var settingsController: SettingsController
    @EnvironmentObject var settingsStore: SettingsStore

    var body: some View {
        VStack(alignment: .leading) {
            Text("Durations")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal)
                .padding(.top, 10)

            HStack {
                Text("Just checking something?")
                    .foregroundColor(.white)
                Spacer()

                Picker(selection: $settingsStore.settings.quickSessionSecs, label: Text("Quick session")) {
                    Text("30 seconds").tag(30 as Int32)
                    Text("45 seconds").tag(45 as Int32)
                    Text("60 seconds").tag(60 as Int32)
                }
                .tint(.parachuteOrange)
                .pickerStyle(.menu)
            }
            .padding(.horizontal)

            HStack {
                Text("Take a break?")
                    .foregroundColor(.white)
                Spacer()
                Picker(selection: $settingsStore.settings.longSessionSecs, label: Text("Long session")) {
                    Text("5 minutes").tag(5 * 60 as Int32)
                    Text("10 minutes").tag(10 * 60 as Int32)
                    Text("15 minutes").tag(15 * 60 as Int32)
                }
                .tint(.parachuteOrange)
                .pickerStyle(.menu)
            }
            .padding(.horizontal)
        }
    }
}

struct AppsPicker: View {
    @EnvironmentObject var settingsController: SettingsController
    @EnvironmentObject var settingsStore: SettingsStore

    var isInstagramEnabled: Binding<Bool> {
        Binding<Bool>(
            get: { settingsStore.settings.isAppEnabled(app: .instagram) },
            set: { newValue in
                settingsStore.settings.setAppEnabled(app: .instagram, value: newValue)
                Task { @MainActor in
                    try await settingsController.syncSettings(reason: "instagram toggle")
                }
            }
        )
    }

    var isTikTokEnabled: Binding<Bool> {
        Binding<Bool>(
            get: { settingsStore.settings.isAppEnabled(app: .tiktok) },
            set: { newValue in
                settingsStore.settings.setAppEnabled(app: .tiktok, value: newValue)
                Task { @MainActor in
                    try await settingsController.syncSettings(reason: "tiktok toggle")
                }
            }
        )
    }

    var isTwitterEnabled: Binding<Bool> {
        Binding<Bool>(
            get: { settingsStore.settings.isAppEnabled(app: .twitter) },
            set: { newValue in
                settingsStore.settings.setAppEnabled(app: .twitter, value: newValue)
                Task { @MainActor in
                    try await settingsController.syncSettings(reason: "twitter toggle")
                }
            }
        )
    }

    var isYoutubeEnabled: Binding<Bool> {
        Binding<Bool>(
            get: { settingsStore.settings.isAppEnabled(app: .youtube) },
            set: { newValue in
                settingsStore.settings.setAppEnabled(app: .youtube, value: newValue)
                Task { @MainActor in
                    try await settingsController.syncSettings(reason: "youtube toggle")
                }
            }
        )
    }

    var isFacebookEnabled: Binding<Bool> {
        Binding<Bool>(
            get: { settingsStore.settings.isAppEnabled(app: .facebook) },
            set: { newValue in
                settingsStore.settings.setAppEnabled(app: .facebook, value: newValue)
                Task { @MainActor in
                    try await settingsController.syncSettings(reason: "facebook toggle")
                }
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading) {
            // Apps
            Text("Apps")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.6))
                .padding(.top, 10)
                .padding(.horizontal)

            VStack {
                Toggle(isOn: isInstagramEnabled) {
                    Text("Instagram")
                        .foregroundColor(.white)
                }
                .padding(.bottom, 10)
                .tint(.parachuteOrange)
                Toggle(isOn: isTikTokEnabled) {
                    Text("TikTok")
                        .foregroundColor(.white)
                }
                .padding(.bottom, 10)
                .tint(.parachuteOrange)
                Toggle(isOn: isTwitterEnabled) {
                    Text("Twitter / X")
                        .foregroundColor(.white)
                }
                .padding(.bottom, 10)
                .tint(.parachuteOrange)
                Toggle(isOn: isYoutubeEnabled) {
                    Text("Youtube")
                        .foregroundColor(.white)
                }
                .padding(.bottom, 10)
                .tint(.parachuteOrange)
                Toggle(isOn: isFacebookEnabled) {
                    Text("Facebook")
                        .foregroundColor(.white)
                }
                .tint(.parachuteOrange)
            }
            .padding(.horizontal)
            Spacer()
        }
    }
}

struct AdvancedSettingsContent: View {
    @EnvironmentObject var settingsStore: SettingsStore

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text("Advanced")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal)
                    .padding(.top, 10)
            }
            HStack {
                Text("Algorithm")
                    .foregroundColor(.white)
                Spacer()
                Picker(selection: $settingsStore.settings.algorithm, label: Text("Algorithm")) {
                    Text("B (recommended)").tag(Proxyservice_Algorithm.proportional)
                    Text("A").tag(Proxyservice_Algorithm.drop)
                }
                .tint(.parachuteOrange)
                .pickerStyle(.menu)
            }
            .padding(.horizontal)
            HStack {
                Text("Usability")
                    .foregroundColor(.white)
                Spacer()
                Picker(selection: $settingsStore.settings.usability, label: Text("Usability")) {
                    Text("Unusable").tag(Proxyservice_Usability.unusable)
                    Text("Barely Usable").tag(Proxyservice_Usability.barely)
                }
                .tint(.parachuteOrange)
                .pickerStyle(.menu)
            }
            .padding(.horizontal)
            Spacer()
        }
    }
}
