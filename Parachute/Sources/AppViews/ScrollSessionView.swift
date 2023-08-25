import SwiftUI
import DI
import Controllers
import AppHelpers
import CommonViews
import Models
import OSLog

public struct ScrollSessionView: View {
    var duration: Int

    public init(duration: Int = 9) {
        self.duration = duration
    }


    static var animation: Animation = .easeInOut(duration: 3)

    var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ScrollSessionView")


    // TODO: remove timerlock
    public var body: some View {
        TimerLock(duration: duration) { timeLeft in
            if timeLeft > 3 {
                Text("Take a deep breath...")
                    .font(.system(size: 24, weight: .bold))
                    .padding([.leading, .trailing, .bottom], 24)
                    .foregroundStyle(Color.parachuteLabel)
                    .transition(.opacity.animation(ScrollSessionView.animation))
            } else if timeLeft == 0 {
                ScrollPrompt(shouldAnimate: duration != 0)
                    .transition(AnyTransition.asymmetric(
                        insertion:.opacity.animation(ScrollSessionView.animation),
                        removal: .identity
                        ))
            } else {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(height: UIScreen.main.bounds.height)
        .buttonBorderShape(.capsule)
    }

}

struct ScrollPrompt: View {
    var shouldAnimate: Bool = true

    @State var showButtons: Bool = false
    @State var showCaption: Bool = false
    
    @EnvironmentObject var scrollSessionViewController: ScrollSessionViewController
    @EnvironmentObject var profileManager: ProfileManager

    private let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ScrollPrompt")
    
    public func startScrollSession() {
        Task { @MainActor in
            do {
                try await profileManager.loadPreset(
                    preset: .focus,
                    overlay: .scrollSession
                )
                if #available(iOS 16.2, *) {
                    await ActivitiesHelper.shared.update(settings: SettingsStore.shared.settings)
                }
                scrollSessionViewController.setClosed()
            } catch {
                logger.error("Failed to load preset: \(error)")
            }
        }
    }

    var body: some View {
        VStack {
            Spacer()
            Text("How are you feeling right now?")
                .font(.system(size: 24, weight: .bold))
                .padding(.bottom, 24)
                .foregroundStyle(Color.parachuteLabel)
            Text("Take a moment and sit with that feeling.")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.secondary)
                .padding(.bottom, 96)
                .foregroundStyle(Color.parachuteLabel)
                .opacity(showCaption ? 1 : 0)
                .animation(ScrollSessionView.animation, value: showCaption)
            HStack {
                Spacer()
                Button(action: {
                    startScrollSession()
                }) {
                    Image(systemName: "play.fill")
                    Text("Scroll for \(Int(Preset.scrollSession.overlayDurationSecs! / 60)) min")
                }
                .buttonStyle(.bordered)
                .tint(.parachuteOrange)
                Spacer()
                Button(action: {
                    scrollSessionViewController.setClosed()
                }) {
                    Text("Never mind")
                }
                .buttonStyle(.bordered)
                .tint(.secondaryFill)
                Spacer()
            }
            .opacity(showButtons ? 1 : 0)
            .animation(ScrollSessionView.animation, value: showButtons)
            Spacer()
        }
        .onAppear {
            Task {@MainActor in
                if shouldAnimate {
                    try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
                }
                showCaption = true
                if shouldAnimate {
                    try await Task.sleep(nanoseconds: 8 * 1_000_000_000)
                }
                showButtons = true
            }
        }
    }
}

struct ScrollSessionView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollSessionView()
            .provideDeps([
                ScrollSessionViewController.Provider()
            ])
    }
}
