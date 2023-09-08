import SwiftUI
import DI
import Controllers
import AppHelpers
import Models
import OSLog
import CommonViews

struct ScrollSessionView: View {
    @Binding var isPresented: Bool

    var body: some View {
        Pane(isPresented: $isPresented, bg: .background) {
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
    @EnvironmentObject var neConfigurationService: NEConfigurationService
    @EnvironmentObject var settingsStore: SettingsStore

    @State var state: ScrollSessionViewPhase = .showLongSession

    public init() {}

    var duration: UInt64 = 1

    var longSessionMinutes: Int {
        Int(settingsStore.settings.longSessionSecs / 60)
    }

    var quickSessionSecs: Int {
        Int(settingsStore.settings.quickSessionSecs)
    }

    var quickSessionIcon: String {
        if quickSessionSecs == 30 {
            return "goforward.30"
        } 
        if quickSessionSecs == 45 {
            return "goforward.45"
        }
        if quickSessionSecs == 60 {
            return "goforward.60"
        }
        return "goforward"
    }

    public var body: some View {
        VStack {
                Text("Take a break?")
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.top, 24)
                    .padding(.bottom, 48)
                Button(action: {
                    Task { @MainActor in
                        ConnectedViewController.shared.set(state: .longSession)
                    }
                }) {
                    HStack {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 24))
                        Spacer()
                        Text("\(longSessionMinutes) MIN")
                    }
                    .foregroundColor(.parachuteOrange)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 20)
                    .contentShape(Rectangle())
                }
                .frame(width: UIScreen.main.bounds.width / 2)  
                .tint(.parachuteOrange)
                .buttonBorderShape(.roundedRectangle)
                .font(.custom("SpaceMono-Regular", size: 16))
                .buttonStyle(.dotted)
                .rrGlow(color: .parachuteOrange, bg: .parachuteOrange.opacity(0.3))
                // .background(
                //     RoundedRectangle(cornerRadius: 20, style: .continuous)
                //         .stroke(style: StrokeStyle(lineWidth: 1))
                //         .foregroundColor(.parachuteOrange.opacity(0.2)))
                // .glow(color: .parachuteOrange.opacity(0.3), radius: 54)
                .opacity(state == .showLongSession ? 1 : 0)
                // .padding(.top, UIScreen.main.bounds.height / 16)

                Spacer()
                Spacer()
                Text("...or just check something?")
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 48)

                Button(action: {
                    Task { @MainActor in
                        var overlay: Preset = .quickBreak
                        overlay.overlayDurationSecs = Double(settingsStore.settings.quickSessionSecs)
                        
                        try await profileManager.loadPreset(
                            preset: .focus,
                            overlay: overlay
                        )
                        ConnectedViewController.shared.set(state: .main)
                        if #available(iOS 16.2, *) {
                            await ActivitiesHelper.shared.update(settings: SettingsStore.shared.settings, isConnected: neConfigurationService.isConnected)
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: quickSessionIcon)
                            .font(.system(size: 24))
                        Spacer()
                        Text("\(quickSessionSecs)s")
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 20)
                    .contentShape(Rectangle())
                }
                .frame(width: UIScreen.main.bounds.width / 2)  
                .tint(.parachuteOrange)
                .buttonBorderShape(.roundedRectangle)
                .font(.custom("SpaceMono-Regular", size: 16))
                .buttonStyle(.dotted)
                .rrGlow(color: .parachuteOrange, bg: .parachuteOrange)
                // .background(
                //     RoundedRectangle(cornerRadius: 20, style: .continuous)
                //         .stroke(style: StrokeStyle(lineWidth: 1))
                //         .foregroundColor(.parachuteOrange.opacity(0.2)))
                // .glow(color: .parachuteOrange.opacity(0.3), radius: 54)
                .opacity(state.shouldShowShortSession ? 1 : 0)
                Spacer()

        }
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
    @EnvironmentObject var neConfigurationService: NEConfigurationService
    @EnvironmentObject var settingsStore: SettingsStore

    var longSessionMinutes: Int {
        Int(settingsStore.settings.longSessionSecs / 60)
    }

    private let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "LongSessionScrollPrompt")
    
    public func startScrollSession() {
        Task { @MainActor in
            do {
                try await profileManager.loadPreset(
                    preset: .focus,
                    overlay: .scrollSession
                )
                if #available(iOS 16.2, *) {
                    await ActivitiesHelper.shared.update(settings: SettingsStore.shared.settings, isConnected: neConfigurationService.isConnected)
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
                    Text("Scroll for \(longSessionMinutes) min")
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


struct ScrollSession_Previews: PreviewProvider {
    init() {
        Fonts.registerFonts()
    }
    static var previews: some View {
        ConnectedPreviewContext {
            ScrollSessionViewInner()
        }
    }
}
