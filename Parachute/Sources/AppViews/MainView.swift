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

    // @Environment(\.scenePhase) var scenePhase

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
        ZStack {
            ConnectedSettingsView(
                isPresented: $isSettingsPresented
            )
            .zIndex(2)

            ScrollSessionView(isPresented: $isScrollSessionPresented)
                .zIndex(2)

            Rectangle()
                .foregroundColor(Color.black.opacity(0.4))
                .edgesIgnoringSafeArea(.all)
                .opacity(isPanePresented ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: isPanePresented)
                .zIndex(1)

            ZStack {
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
                        // .rr(color: .white, bg: .clear)
                        Spacer()

                        // .background {
                        //     RoundedRectangle(cornerRadius: 20, style: .continuous)
                        //         .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        //         .background(Color.background.opacity(0.8))
                        //         .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        //         .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        // }
                        // TextLogo()
                        // Spacer()
                    }
                    .padding(.horizontal)
                    .foregroundColor(.white.opacity(0.5))
                    .zIndex(0)
                    Spacer()
                    // AppPicker()
                    Spacer()
                    SimpleSelector()
                    Spacer()
                }
                //                .padding(.top, topPadding)
                // .frame(height: UIScreen.main.bounds.height / 2, alignment: .bottom)
                .zIndex(0)

                VStack {
                    SlowdownWidgetView(settings: settingsStore.settings, isConnected: neConfigurationService.isConnected)
                        // .padding(.vertical, 20)
                        .padding(.horizontal, 20)
                        //                        .rrGlow(color: .white, bg: .clear)
                        // .background {
                        //     RoundedRectangle(cornerRadius: 20, style: .continuous)
                        //         .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        //         .background(Color.background.opacity(0.8))
                        //         .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        //         .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        // }
                        .padding()
                        .padding(.top, topPadding / 2)
                        .frame(maxWidth: .infinity, alignment: .top)
                    Spacer()
                }
            }
            .blur(radius: isPanePresented ? 8 : 0)
            .scaleEffect(isPanePresented ? 0.98 : 1) // Add scale effect when settings page is open
            .animation(.easeInOut(duration: 0.2), value: isPanePresented) // Add animation to the blur effect
            .zIndex(0)
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
