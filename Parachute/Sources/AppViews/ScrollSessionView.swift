import CommonViews
import Controllers
import DI
import Models
import OSLog
import SwiftUI

struct ScrollSessionView: View {
    @EnvironmentObject var connectedViewController: ConnectedViewController

    var body: some View {
        Pane(isPresented: connectedViewController.isScrollSessionPresented, bg: .background) {
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

struct FullWidthCard<Content: View>: View {
    var icon: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            // .padding(.vertical)
            .frame(width: UIScreen.main.bounds.width)
    }
}

public struct ScrollSessionViewInner: View {
    @EnvironmentObject var connectedViewController: ConnectedViewController
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var settingsController: SettingsController
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

    public var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("Let me...")
                    .font(.mainFont(size: 24))
                    .foregroundColor(.parachuteLabel.opacity(0.8))
                    .padding(.vertical)
            }

            FullWidthCard(icon: "arrow.up.arrow.down") {
                HStack {

                    Spacer()

                    Button(action: {
                        Task { @MainActor in
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            ConnectedViewController.shared.set(state: .longSession)
                        }
                    }) {
                        Text(try! AttributedString(
                            markdown: "**Scroll** and relax for a bit."
                            // boldFont: .custom("SpaceMono-Regular", size: 16).bold()
                        )
                        )
                        .foregroundColor(.parachuteOrange)
                        .padding()
                    }
                    .buttonStyle(.bordered)
                    .tint(.parachuteOrange)
                    // .rrGlow(color: .parachuteOrange, bg: .parachuteOrange.opacity(0.3))
                    .opacity(state == .showLongSession ? 1 : 0)
                }
            }
            FullWidthCard(icon: "goforward") {
                HStack {
                    Spacer()
                    // HStack {
                    //     Text("check...")
                    //         .font(.custom("SpaceMono-Regular", size: 32))
                    //         .foregroundColor(.parachuteLabel)
                    //         .padding(24)
                    //     Spacer()
                    // }
                    Button(action: {
                        actionController.startQuickSession()
                    }) {
                        Text(try! AttributedString(
                            markdown: "**Check** something really quick."
                            // boldFont: .custom("SpaceMono-Regular", size: 16).bold()
                        )
                        )
                        .foregroundColor(.black)
                        .padding()
                    }
                    .tint(.parachuteOrange)
                    .buttonStyle(.borderedProminent)
                    // .rrGlow(color: .parachuteOrange, bg: .parachuteOrange)
                    .opacity(state.shouldShowShortSession ? 1 : 0)
                }
            }
        }
        .buttonBorderShape(.roundedRectangle(radius: 20))
        .font(.mainFont(size: 16))
        Rectangle()
            .fill(.clear)
            .frame(height: 200)
    }
}

enum LongSessionViewPhase: Comparable {
    case initial
    case promptBreathe
    case promptBreatheEnd
    case promptScroll
}

public struct LongSessionView: View {
    static var inhaleDuration: Double = 5

    var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "LongSessionView")

    @State var state: LongSessionViewPhase = .initial

    public init() {}
    public var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            Text("Take a deep breath...")
                .font(.mainFont(size: 24))
                .foregroundStyle(Color.parachuteLabel.opacity(0.8)) 
                .opacity(state == .promptBreathe ? 1 : 0)
                .padding()
                .animation(.easeInOut(duration: LongSessionView.inhaleDuration), value: state)

            Spacer()

            LongSessionScrollPrompt()
                .opacity(state == .promptScroll ? 1 : 0)
                .animation(.easeInOut(duration: 1), value: state)
                .frame(width: UIScreen.main.bounds.width)
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
        .frame(width: UIScreen.main.bounds.width, height: UIApplication.shared.connectedScenes.first?.inputView?.frame.height)
        .buttonBorderShape(.roundedRectangle(radius: 20))
        .font(.mainFont(size: 16))
    }
}

struct LongSessionScrollPrompt: View {
    @State var showButtons: Bool = false
    @State var showCaption: Bool = false

    @EnvironmentObject var connectedViewController: ConnectedViewController
    @EnvironmentObject var settingsController: SettingsController
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var actionController: ActionController

    var longSessionMinutes: Int {
        Int(settingsStore.settings.longSessionSecs / 60)
    }

    private let logger: Logger = .init(subsystem: Bundle.main.bundleIdentifier!, category: "LongSessionScrollPrompt")

    var body: some View {
        VStack (alignment: .trailing){
            // HStack {
            //     Text("Still want to scroll?")
            //         .font(.mainFont(size: 24))
            //     // .font(.system(size: 18, weight: .regular, design: .rounded))
            //         .foregroundColor(.parachuteLabel.opacity(0.8))
            //         .padding(.vertical)
            //         .foregroundStyle(Color.parachuteLabel)
            //     Spacer()
            // }

            HStack {
                let (before, after) = settingsStore.longSessionSecsAdjacentOptions

                Spacer()

                VStack {
                    Button(action: {
                        if let after = after {
                            Task { @MainActor in
                                settingsStore.settings.longSessionSecs = Int32(after)
                                try await settingsController.syncSettings()
                            }
                        }
                    }) {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 18))
                            .foregroundColor(.parachuteOrange)
                            .padding(4)
                            .contentShape(Rectangle())
                    }
                    .opacity(after != nil ? 1 : 0.2)

                    Button(action: {
                        if let before = before {
                            Task { @MainActor in
                                settingsStore.settings.longSessionSecs = Int32(before)
                                try await settingsController.syncSettings()
                            }
                        }
                    }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 18))
                            .foregroundColor(.parachuteOrange)
                            .padding(4)
                            .contentShape(Rectangle())
                    }
                    .opacity(before != nil ? 1 : 0.2)
                }

                Button(action: {
                    actionController.startLongSession()
                }) {
                    Text("Scroll for \(longSessionMinutes) min")
                        .frame(width: UIScreen.main.bounds.width / 2)
                    .padding()
                }
                .buttonStyle(.bordered)
                .tint(.parachuteOrange)
            }

            Button(action: {
                connectedViewController.set(state: .main)
            }) {
                Text("Never mind")
                    .padding()
            }
            .buttonStyle(.bordered)
            .tint(.secondaryFill)
        }
        Rectangle()
            .fill(.clear)
            .frame(height: 200)
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
