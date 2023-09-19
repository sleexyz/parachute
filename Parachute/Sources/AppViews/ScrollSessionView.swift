import CommonViews
import Controllers
import DI
import Models
import OSLog
import SwiftUI

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
            false
        case .showShortSession, .showLongSession:
            true
        }
    }
}

public struct ScrollSessionViewInner: View {
    @EnvironmentObject var connectedViewController: ConnectedViewController
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var actionController: ActionController

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
            Spacer()

            Text("Just checking something?")
                .font(.system(size: 20, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.bottom, 48)

            Button(action: {
                actionController.startQuickSession()
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
            .opacity(state.shouldShowShortSession ? 1 : 0)

            Spacer()
            Spacer()

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
            .opacity(state == .showLongSession ? 1 : 0)

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
            Task { @MainActor in
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

    @EnvironmentObject var connectedViewController: ConnectedViewController
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var actionController: ActionController

    var longSessionMinutes: Int {
        Int(settingsStore.settings.longSessionSecs / 60)
    }

    private let logger: Logger = .init(subsystem: Bundle.main.bundleIdentifier!, category: "LongSessionScrollPrompt")


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
                    actionController.startLongSession()
                }) {
                    Image(systemName: "play.fill")
                    Text("Scroll for \(longSessionMinutes) min")
                }
                .buttonStyle(.bordered)
                .tint(.parachuteOrange)
                Spacer()
                Button(action: {
                    connectedViewController.set(state: .main)
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
