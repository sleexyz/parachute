import SwiftUI
import Controllers
import CommonViews

struct SettingsContent: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var vpnLifecycleManager: VPNLifecycleManager

    var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                vpnLifecycleManager.pauseConnection()
                isPresented = false
            }, label: {
                Text("Disable Parachute")
                    .foregroundColor(.white)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white, lineWidth: 1)
                            .background(Color.white.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    )
            })
            .padding()

            TimePicker()
                .padding(.bottom, 20)
            AppsPicker()
                .padding(.bottom, 20)
        }
    }
}

struct TimePicker: View {
    @EnvironmentObject var settingsController: SettingsController
    @EnvironmentObject var settingsStore: SettingsStore

    var body: some View {
        VStack(alignment: .leading) {
            Text("Session Lengths")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal)
                .padding(.top, 10)

            HStack {
                Text("Quick")
                    .foregroundColor(.white)
                Spacer()
                HStack {
                    Button(action: {
                        settingsStore.settings.quickSessionSecs = 30
                        Task {
                            try await settingsController.syncSettings(reason: "session length 30s")
                        }
                    }, label: {
                        Text("30\"")
                            .foregroundColor(settingsStore.settings.quickSessionSecs == 30 ? .white : .gray)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(settingsStore.settings.quickSessionSecs == 30 ? Color.white.opacity(0.2) : Color.clear)
                            .cornerRadius(20)
                    })
                    
                    Button(action: {
                        settingsStore.settings.quickSessionSecs = 45
                        Task {
                            try await settingsController.syncSettings(reason: "session length 45s")
                        }
                    }, label: {
                        Text("45\"")
                            .foregroundColor(settingsStore.settings.quickSessionSecs == 45 ? .white : .gray)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(settingsStore.settings.quickSessionSecs == 45 ? Color.white.opacity(0.2) : Color.clear)
                            .cornerRadius(20)
                    })
                    
                    Button(action: {
                        settingsStore.settings.quickSessionSecs = 60
                        Task {
                            try await settingsController.syncSettings(reason: "session length 60s")
                        }
                    }, label: {
                        Text("60\"")
                            .foregroundColor(settingsStore.settings.quickSessionSecs == 60 ? .white : .gray)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(settingsStore.settings.quickSessionSecs == 60 ? Color.white.opacity(0.2) : Color.clear)
                            .cornerRadius(20)
                    })
                }
            }
            .padding(.horizontal)

            HStack {
                Text("Long")
                    .foregroundColor(.white)
                Spacer()
                HStack {
                    Button(action: {
                        settingsStore.settings.longSessionSecs = 180
                        Task {
                            try await settingsController.syncSettings(reason: "session length 180s")
                        }
                    }, label: {
                        Text("3'")
                            .foregroundColor(settingsStore.settings.longSessionSecs == 180 ? .white : .gray)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(settingsStore.settings.longSessionSecs == 180 ? Color.white.opacity(0.2) : Color.clear)
                            .cornerRadius(20)
                    })
                    
                    Button(action: {
                        settingsStore.settings.longSessionSecs = 300
                        Task {
                            try await settingsController.syncSettings(reason: "session length 300s")
                        }
                    }, label: {
                        Text("5'")
                            .foregroundColor(settingsStore.settings.longSessionSecs == 300 ? .white : .gray)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(settingsStore.settings.longSessionSecs == 300 ? Color.white.opacity(0.2) : Color.clear)
                            .cornerRadius(20)
                    })
                    
                    Button(action: {
                        settingsStore.settings.longSessionSecs = 480
                        Task {
                            try await settingsController.syncSettings(reason: "session length 480s")
                        }
                    }, label: {
                        Text("8'")
                            .foregroundColor(settingsStore.settings.longSessionSecs == 480 ? .white : .gray)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(settingsStore.settings.longSessionSecs == 480 ? Color.white.opacity(0.2) : Color.clear)
                            .cornerRadius(20)
                    })
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
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

    var body: some View {
        VStack(alignment: .leading) {
            // Apps
            Text("Apps")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal)
                .padding(.top, 10)

            
            Toggle(isOn: isInstagramEnabled) {
                Text("Instagram")
                    .foregroundColor(.white)
            }
            .tint(.parachuteOrange)
            .padding()
            Toggle(isOn: isTikTokEnabled) {
                Text("TikTok")
                    .foregroundColor(.white)
            }
            .tint(.parachuteOrange)
            .padding()
            Toggle(isOn: isTwitterEnabled) {
                Text("Twitter (X)")
                    .foregroundColor(.white)
            }
            .tint(.parachuteOrange)
            .padding()
            Toggle(isOn: isYoutubeEnabled) {
                Text("Youtube")
                    .foregroundColor(.white)
            }
            .tint(.parachuteOrange)
            .padding()

            Spacer()
        }
    }
}

struct SettingsView: View {
    @Binding var isPresented: Bool

    var body: some View {
        Pane(isPresented: $isPresented, bg: .background) {
            SettingsContent(isPresented: $isPresented)
        }
    }
}
