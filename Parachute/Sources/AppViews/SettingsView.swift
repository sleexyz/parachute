import SwiftUI
import Controllers
import CommonViews

struct SettingsContent: View {
    @EnvironmentObject var vpnLifecycleManager: VPNLifecycleManager
    @Binding var isPresented: Bool
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 40, height: 5)
                    .padding(.top, 10)
                    .padding(.bottom, 5)
                Spacer()
            }
            .contentShape(Rectangle())

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
            Spacer()
        }
    }
}

struct SettingsView: View {
    @Binding var isPresented: Bool
    @GestureState private var dragAmount = CGSize.zero

    var topOffset: CGFloat {
        UIApplication.shared.connectedScenes.first?.inputView?.safeAreaInsets.top ?? 0 + 10 ?? 0
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    .background(Color.darkBlueBg)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(minHeight: UIScreen.main.bounds.height)

                SettingsContent(isPresented: $isPresented)
            }
            .offset(y: isPresented ? topOffset + dragAmount.height : geometry.size.height + 100) // Set the offset to 0 when isSettingsPresented is true
            .animation(Animation.easeOut(duration: 0.15), value: isPresented)
            .animation(Animation.easeInOut(duration: 0.2), value: dragAmount)
            .gesture(
                DragGesture()
                    .updating($dragAmount) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        if value.translation.height > 0 {
                            isPresented = false
                        } else {
                            isPresented = true
                        }
                    }
            )
        }
    }
}
