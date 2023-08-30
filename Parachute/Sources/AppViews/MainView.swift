import SwiftUI
import Controllers
import CommonViews

struct TextLogo: View {
    var body: some View {
        HStack {
            Image(systemName: "drop.fill")
                .font(.system(size: 28, design: .rounded))
                .fontWeight(.bold)
                .padding(.trailing, 4)

            Text("faucet")
                .font(.system(.title, design: .rounded))
                // .font(.custom("SpaceMono-Regular", size: 26))
                // .textCase(.uppercase)
                .fontWeight(.bold)
        }
            .foregroundStyle(Color.parachuteOrange)
    }
}

public struct MainView: View {
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var vpnLifecycleManager: VPNLifecycleManager
    @EnvironmentObject var connectedViewController: ConnectedViewController

    @State private var isFeedbackOpen = false
    
    @Binding var isSettingsPresented: Bool
    @Binding var isScrollSessionPresented: Bool

    var isPanePresented: Bool {
        isSettingsPresented || isScrollSessionPresented
    }
    
    public init() {
        self._isSettingsPresented = ConnectedViewController.shared.isSettingsPresented
        self._isScrollSessionPresented = ConnectedViewController.shared.isScrollSessionPresented
    }

    var topPadding: CGFloat = 200
    
    public var body: some View {
        ZStack {
            SettingsView(isPresented: $isSettingsPresented)
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
                    SlowdownWidgetView(settings: settingsStore.settings)
                        // .padding(.vertical, 20)
                        .padding(.horizontal, 20)
                        .rrGlow(color: .white, bg: .clear)
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
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            isSettingsPresented = true
                        }, label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 28))
                                .padding()
                        })
                        .buttonStyle(.plain)
                        .rr(color: .white, bg: .clear)
                        // .background {
                        //     RoundedRectangle(cornerRadius: 20, style: .continuous)
                        //         .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        //         .background(Color.background.opacity(0.8))
                        //         .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        //         .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        // }
                        // TextLogo()
                        // Spacer()
                        // Button(action: {
                        //     UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        //     isFeedbackOpen = true
                        // }, label: {
                        //     Image(systemName: "bubble.right.fill")
                        //         .font(.system(size: 28))
                        //         .padding()
                        // })
                        // .buttonStyle(.plain)
                        // .alert("Feedback open", isPresented: $isFeedbackOpen) {
                        //     Button("OK") {
                        //         isFeedbackOpen = false
                        //     }
                        // }
                    }
                    .padding(.horizontal)
                    .foregroundColor(.white.opacity(0.5))
                    .zIndex(0)
                    Spacer()
                    SimpleSelector()
                    Spacer()
                }
                .padding(.top, topPadding)
                // .frame(height: UIScreen.main.bounds.height / 2, alignment: .bottom)
                .zIndex(0)

            }
            .blur(radius: isPanePresented ? 8 : 0)
            .scaleEffect(isPanePresented ? 0.98 : 1) // Add scale effect when settings page is open
            .animation(.easeInOut(duration: 0.2), value: isPanePresented) // Add animation to the blur effect
            .zIndex(0)
        }
    }
}
