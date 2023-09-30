import Combine
import CommonViews
import Controllers
import OSLog
import SwiftUI

public struct MainView: View {
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var vpnLifecycleManager: VPNLifecycleManager
    @EnvironmentObject var connectedViewController: ConnectedViewController
    @EnvironmentObject var neConfigurationService: NEConfigurationService
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var activitiesHelper: ActivitiesHelper

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "MainView")

    @Environment(\.scenePhase) var scenePhase

    @Binding var isSettingsPresented: Bool
    @Binding var isScrollSessionPresented: Bool

    var isPanePresented: Bool {
        isSettingsPresented || isScrollSessionPresented
    }

    public init() {
        _isSettingsPresented = ConnectedViewController.shared.isSettingsPresented
        _isScrollSessionPresented = ConnectedViewController.shared.isScrollSessionPresented
    }

    var topPadding: CGFloat = 200

    public var body: some View {
        VStack {
            HStack {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    isSettingsPresented = true
                }, label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 28))
                        .padding()
                })
                .buttonStyle(.plain)
                Spacer()
            }
            .padding(.horizontal)
            .foregroundColor(.white.opacity(0.5))
            .zIndex(0)

            SlowdownWidgetView(settings: settingsStore.settings, isConnected: neConfigurationService.isConnected)
                .padding(.horizontal, 20)
                .padding(.top)
                .padding()
                .frame(maxWidth: .infinity, alignment: .top)

            Spacer()

            SimpleSelector()
                .padding()

            Spacer()
        }
        .zIndex(0)
        .sheet(isPresented: ConnectedViewController.shared.isSettingsPresented) {
            SettingsView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .onChange(of: scenePhase) { phase in
            // Reload settings when app becomes active
            // in case they were changed in the widget
            if phase == .active {
                // logger.info("active")
                do {
                    try settingsStore.load()
                    logger.info("loaded!")
                } catch {
                    logger.info("error loading settings: \(error)")
                }
            }
        }
    }
}

struct TextLogo: View {
    var body: some View {
        HStack {
            // Image(systemName: "drop.fill")
            //     .font(.system(size: 28, design: .rounded))
            //     .fontWeight(.bold)
            //     .padding(.trailing, 4)

            Text("parachute.")
                .font(.system(.title, design: .rounded))
                // .font(.custom("SpaceMono-Regular", size: 26))
                // .textCase(.uppercase)
                .fontWeight(.bold)
        }
        .foregroundStyle(Color.parachuteOrange)
    }
}
