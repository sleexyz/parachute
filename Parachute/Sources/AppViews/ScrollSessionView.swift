import SwiftUI
import DI
import Controllers
import AppHelpers
import CommonViews
import Models
import Logging

public struct ScrollSessionView: View {
    public init() {}
    static var animation: Animation = .easeInOut(duration: 3)

    var logger = Logger(label: "industries.strange.slowdown.ScrollSessionView")


    // TODO: remove timerlock
    public var body: some View {
        TimerLock(duration: 9) { timeLeft in
            if timeLeft > 3 {
                Text("Take a deep breath...")
                    .font(.system(size: 24, weight: .bold))
                    .padding([.leading, .trailing, .bottom], 24)
                    .foregroundStyle(Color(UIColor.label))
                    .transition(.opacity.animation(ScrollSessionView.animation))
            } else if timeLeft == 0 {
                ScrollPrompt()
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
    @State var showButtons: Bool = false
    @State var showCaption: Bool = false
    
    @EnvironmentObject var scrollSessionViewController: ScrollSessionViewController
    @EnvironmentObject var profileManager: ProfileManager

    
    public func startScrollSession() {
        Task { @MainActor in
            try await profileManager.loadPreset(
                preset: .focus,
                overlay: .scrollSession
            )
            if #available(iOS 16.2, *) {
                await ActivitiesHelper.shared.update(settings: SettingsStore.shared.settings)
            }
            scrollSessionViewController.setClosed()
        }
    }

    var body: some View {
        VStack {
            Spacer()
            Text("How are you feeling right now?")
                .font(.system(size: 24, weight: .bold))
                .padding(.bottom, 24)
                .foregroundStyle(Color(UIColor.label))
            Text("Take a moment and sit with that feeling.")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.secondary)
                .padding(.bottom, 96)
                .foregroundStyle(Color(UIColor.label))
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
                try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
                showCaption = true
                try await Task.sleep(nanoseconds: 6 * 1_000_000_000)
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
