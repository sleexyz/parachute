import SwiftUI
import DI
import Controllers
import AppHelpers
import CommonViews
import Models
import OSLog

struct ScrollSessionView: View {
    @Binding var isPresented: Bool

    var body: some View {
        Pane(isPresented: $isPresented) {
            ScrollSessionViewInner()
        }
    }
}

enum ScrollSessionViewPhase {
    case initial
    case showShortSession
    case showLongSession

    var shouldShowShortSession: Bool {
        switch self {
        case .initial: 
            return false
        case .showShortSession, .showLongSession:
            return true
        }
    }
}

public struct ScrollSessionViewInner: View {
    @EnvironmentObject var connectedViewController: ConnectedViewController 
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var settingsStore: SettingsStore

    @State var state: ScrollSessionViewPhase = .showLongSession

    public init() {}

    var duration: UInt64 = 1

    public var body: some View {
        VStack {
            Button(action: {
                Task { @MainActor in
                    var overlay: Preset = .quickBreak
                    overlay.overlayDurationSecs = Double(settingsStore.settings.quickSessionSecs)
                    
                    try await profileManager.loadPreset(
                        preset: .focus,
                        overlay: overlay
                    )
                    if #available(iOS 16.2, *) {
                        await ActivitiesHelper.shared.update(settings: SettingsStore.shared.settings)
                    }
                    ConnectedViewController.shared.set(state: .main)
                }
            }) {
                Image(systemName: "goforward.30")
                    .font(.system(size: 48))
                    .padding()
            }
            .tint(.parachuteOrange)
            .buttonBorderShape(.capsule)
            .buttonStyle(.borderedProminent)
            .opacity(state.shouldShowShortSession ? 1 : 0)
            .padding(.vertical, 36)

            Button(action: {
                Task { @MainActor in
                    ConnectedViewController.shared.set(state: .longSession)
                }
            }) {
                Text("5 min")
                    .font(.title)
                    .padding()
            }
            .tint(.parachuteOrange)
            .buttonBorderShape(.capsule)
            .buttonStyle(.bordered)
            .opacity(state == .showLongSession ? 1 : 0)
            .padding(.vertical, 36)


        }
        // .frame(minHeight: 0, maxHeight: UIScreen.main.bounds.height * 0.6, alignment: .center)
        // .onAppear {
        //     Task {@MainActor in
        //         state = .showShortSession
        //         try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
        //         state = .showLongSession
        //     }
        // }
        // .animation(.easeInOut(duration: Double(duration)), value: state)
    }
}

enum LongSessionViewPhase {
    case initial
    case promptBreathe
    case promptBreatheEnd
    case promptScroll
}

public struct LongSessionView: View {
    static var inhaleDuration: Double = 4

    var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "LongSessionView")

    @State var state: LongSessionViewPhase = .initial

    public init() {}
    public var body: some View {
        VStack {
            Spacer()
            Text("Take a deep breath...")
                .font(.system(size: 24, weight: .bold))
                .padding([.leading, .trailing, .bottom], 24)
                .foregroundStyle(Color.parachuteLabel)
                .opacity(state == .promptBreathe ? 1 : 0)
                .animation(.easeInOut(duration: LongSessionView.inhaleDuration), value: state) 

            LongSessionScrollPrompt()
                .opacity(state == .promptScroll ? 1 : 0)
                .animation(.easeInOut(duration: 1), value: state) 

            Spacer()
        }
        .onAppear {
            Task {@MainActor in
                state = .promptBreathe
                try await Task.sleep(nanoseconds: UInt64(LongSessionView.inhaleDuration * 1_000_000_000))
                state = .promptBreatheEnd
                try await Task.sleep(nanoseconds: UInt64(LongSessionView.inhaleDuration * 1_000_000_000))
                state = .promptScroll
            }
        }
        .frame(height: UIApplication.shared.connectedScenes.first?.inputView?.frame.height)
        .buttonBorderShape(.capsule)
    }

}


struct LongSessionScrollPrompt: View {
    @State var showButtons: Bool = false
    @State var showCaption: Bool = false
    
    @EnvironmentObject var scrollSessionViewController: ConnectedViewController
    @EnvironmentObject var profileManager: ProfileManager

    private let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "LongSessionScrollPrompt")
    
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
                scrollSessionViewController.set(state: .main)
            } catch {
                logger.error("Failed to load preset: \(error)")
            }
        }
    }

    var body: some View {
        VStack {
            Text("Still want to scroll?")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.secondary)
                .padding(.bottom, 96)
                .foregroundStyle(Color.parachuteLabel)
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
                    scrollSessionViewController.set(state: .main)
                }) {
                    Text("Never mind")
                }
                .buttonStyle(.bordered)
                .tint(.secondaryFill)
                Spacer()
            }
        }
    }
}

struct ScrollSessionView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectedPreviewContext {
            ScrollSessionViewInner()
                .provideDeps([
                    ConnectedViewController.Provider()
                ])
        }
    }
}
