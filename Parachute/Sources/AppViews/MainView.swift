import SwiftUI
import Controllers
import CommonViews

public struct MainView: View {
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var vpnLifecycleManager: VPNLifecycleManager
    @EnvironmentObject var connectedViewController: ConnectedViewController

    @State private var isFeedbackOpen = false
    
    @Binding var isSettingsPresented: Bool
    @Binding var isScrollSessionPresented: Bool

    
    public init() {
        self._isSettingsPresented = ConnectedViewController.shared.isSettingsPresented
        self._isScrollSessionPresented = ConnectedViewController.shared.isScrollSessionPresented
    }
    
    public var body: some View {
        ZStack {
            SettingsView(isPresented: $isSettingsPresented)
            .zIndex(2)

            ScrollSessionView(isPresented: $isScrollSessionPresented)
            .zIndex(2)
            
            Rectangle()
                .foregroundColor(Color.black.opacity(0.4))
                .edgesIgnoringSafeArea(.all)
                .opacity(isSettingsPresented ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: isSettingsPresented)
                .zIndex(1)
                .onTapGesture {
                    isSettingsPresented = false
                }

            ZStack {
                VStack {
                    SlowdownWidgetView(settings: settingsStore.settings)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 20)
                        // .rrGlow(color: .white, bg: .darkBlueBg)
                        .background {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                .background(Color.background.opacity(0.8))
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        }
                        .padding(.top, 80)
                        .padding()
                    Spacer()
                    Spacer()
                    Spacer()
                    SimpleSelector()
                    Spacer()
                }
                .zIndex(0)

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
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            isFeedbackOpen = true
                        }, label: {
                            Image(systemName: "bubble.right.fill")
                                .font(.system(size: 28))
                                .padding()
                        })
                        .buttonStyle(.plain)
                        .alert("Feedback open", isPresented: $isFeedbackOpen) {
                            Button("OK") {
                                isFeedbackOpen = false
                            }
                        }
                    }
                    .foregroundColor(.white.opacity(0.5))
                    Spacer()
                }
                .zIndex(0)
            }
            .blur(radius: isSettingsPresented || isScrollSessionPresented ? 8 : 0)
            .scaleEffect(isSettingsPresented || isScrollSessionPresented ? 0.98 : 1) // Add scale effect when settings page is open
            .animation(.easeInOut(duration: 0.2), value: isSettingsPresented || isScrollSessionPresented) // Add animation to the blur effect
            .zIndex(0)
        }
    }
}
