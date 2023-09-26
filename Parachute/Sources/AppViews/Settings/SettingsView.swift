import CommonViews
import Controllers
import ProxyService
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var connectedViewController: ConnectedViewController
    @State private var isFeedbackOpen = false

    @Binding var isPresented: Bool
    @Binding var isAdvancedPresented: Bool

    public init() {
        _isPresented = ConnectedViewController.shared.isSettingsPresented
        _isAdvancedPresented = ConnectedViewController.shared.isAdvancedSettingsPresented
    }

    var body: some View {
        SettingsSyncer {
            NavigationStack {
                HStack {
                    DisableButton()
                        .padding()

                    Spacer()

                    FeedbackButton()
                        .padding()
                        .foregroundColor(.parachuteOrange)
                }
                .padding(.top, 20)
                List {
                    TimePicker()

                    Section {
                        NavigationLink {
                            ScheduleView()
                        } label: {
                            Text("Schedule")
                            // .font(.system(size: 16, weight: .regular, design: .rounded))
                            // .foregroundColor(.white.opacity(0.6))
                            // .padding()
                            // .background(Material.ultraThinMaterial)
                            // .cornerRadius(20)
                        }
                    }

                    AppsPicker()

                    Section {
                        NavigationLink {
                            AdvancedSettingsContent()
                        } label: {
                            Text("Advanced")
                            // .font(.system(size: 16, weight: .regular, design: .rounded))
                            // .foregroundColor(.white.opacity(0.6))
                            // .padding()
                            // .background(Material.ultraThinMaterial)
                            // .cornerRadius(20)
                        }
                    }
                }
            }
        }
        .tint(.parachuteOrange)
        .font(.system(size: 16, weight: .regular, design: .rounded))
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
    var label: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text(label)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.trailing, 20)
            }
        }
        .contentShape(Rectangle())
    }
}

struct DisableButton: View {
    @EnvironmentObject var connectedViewController: ConnectedViewController
    @EnvironmentObject var vpnLifecycleManager: VPNLifecycleManager

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            vpnLifecycleManager.disable(until: Date(timeIntervalSinceNow: 60 * 60))
            // vpnLifecycleManager.pauseConnection(until: Date(timeIntervalSinceNow: 60 * 60))
            connectedViewController.isSettingsPresented.wrappedValue = false
        }, label: {
            Text("Disable Parachute for 1 hour")
                .font(.system(size: 18, design: .rounded))
            // .multilineTextAlignment(.leading)
        })
        .padding()
        .tint(.parachuteOrange)
        .rr(color: .parachuteOrange)
    }
}

struct TimePicker: View {
    @EnvironmentObject var settingsController: SettingsController
    @EnvironmentObject var settingsStore: SettingsStore

    var body: some View {
        Section {
            Picker(selection: $settingsStore.settings.quickSessionSecs, label: Text("Check duration")) {
                Text("30 seconds").tag(30 as Int32)
                Text("45 seconds").tag(45 as Int32)
                Text("60 seconds").tag(60 as Int32)
            }
            .tint(.parachuteOrange)
            .pickerStyle(.menu)
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
        Section(header: Text("Apps")) {
            Toggle(isOn: isInstagramEnabled) {
                Text("Instagram")
                    .foregroundColor(.white)
            }
            Toggle(isOn: isTikTokEnabled) {
                Text("TikTok")
                    .foregroundColor(.white)
            }
            Toggle(isOn: isTwitterEnabled) {
                Text("Twitter / X")
                    .foregroundColor(.white)
            }
            Toggle(isOn: isYoutubeEnabled) {
                Text("Youtube")
                    .foregroundColor(.white)
            }
            Toggle(isOn: isFacebookEnabled) {
                Text("Facebook")
                    .foregroundColor(.white)
            }
        }
        .tint(.parachuteOrange)
    }
}

struct AdvancedSettingsContent: View {
    @EnvironmentObject var settingsStore: SettingsStore

    var body: some View {
        List {
            Section {
                Picker(selection: $settingsStore.settings.algorithm, label: Text("Algorithm")) {
                    Text("B (recommended)").tag(Proxyservice_Algorithm.proportional)
                    Text("A").tag(Proxyservice_Algorithm.drop)
                }
                .pickerStyle(.menu)
                Picker(selection: $settingsStore.settings.usability, label: Text("Usability")) {
                    Text("Unusable").tag(Proxyservice_Usability.unusable)
                    Text("Barely Usable").tag(Proxyservice_Usability.barely)
                }
                .pickerStyle(.menu)
            }
        }
        .navigationTitle("Advanced")
        .tint(.parachuteOrange)
    }
}
