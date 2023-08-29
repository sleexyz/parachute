import SwiftUI
import Controllers
import CommonViews

public struct MainView: View {
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var vpnLifecycleManager: VPNLifecycleManager
    @State private var isSettingsPresented = false
    @State private var isFeedbackOpen = false
    
    public init() {}
    public var body: some View {
        ZStack {
            SettingsView(isPresented: $isSettingsPresented) 
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
                    Spacer()
                    SlowdownWidgetView(settings: settingsStore.settings)
                        .padding()
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
            .blur(radius: isSettingsPresented ? 5 : 0)
            .scaleEffect(isSettingsPresented ? 0.98 : 1) // Add scale effect when settings page is open
            .animation(.easeInOut(duration: 0.2), value: isSettingsPresented) // Add animation to the blur effect
            .zIndex(0)
        }
    }
}
