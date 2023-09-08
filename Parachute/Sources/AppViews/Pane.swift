import SwiftUI

public struct Pane<Content: View>: View {
    @Binding var isPresented: Bool
    @GestureState private var dragAmount = CGSize.zero

    @ViewBuilder let content: () -> Content

    var bg: Color

    public init(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        self.init(isPresented: isPresented, bg: Color.darkBlueBg, content: content)
    }

    public init(isPresented: Binding<Bool>, bg: Color, @ViewBuilder content: @escaping () -> Content) {
        _isPresented = isPresented
        self.content = content
        self.bg = bg
    }

    var topOffset: CGFloat = 44

    var bottomPadding: CGFloat = 40

    public var body: some View {
        VStack {
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 40, height: 5)
                    .padding(.top, 10)
                Spacer()
            }
            content()
                .padding(.bottom, bottomPadding)
        }
        .background(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                .frame(width: UIScreen.main.bounds.width)
                .background(bg.opacity(1))
                .background(Material.ultraThinMaterial.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .contentShape(Rectangle())
                .zIndex(0)
        }
        .frame(minHeight: 0, maxHeight: UIScreen.main.bounds.height - topOffset, alignment: .bottom)
        // .offset(y: isPresented ? topOffset + dragAmount.height : geometry.size.height + 100) // Set the offset to 0 when isSettingsPresented is true
        .offset(y: isPresented ? max(dragAmount.height, 0) + bottomPadding : UIScreen.main.bounds.height) // Set the offset to 0 when isSettingsPresented is true
        .animation(Animation.easeOut(duration: 0.15), value: isPresented).animation(Animation.easeInOut(duration: 0.2), value: dragAmount)
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
        .onChange(of: isPresented) { newValue in
            if newValue {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        }
        .frame(maxHeight: UIScreen.main.bounds.height - topOffset, alignment: .top)
    }
}
