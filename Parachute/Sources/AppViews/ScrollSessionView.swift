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
        VStack(alignment: .leading) {
            // RoundedRectangle(cornerRadius: 20, style: .continuous)
            //     .fill(Color(UIColor(white: 0.1, alpha: 1)))
            //     .frame(width: 80, height: 80 * 2)
            //     .padding(.top, -40)
            Spacer()

            content()
                .padding(.vertical, 20)

            Spacer()

            // Image(systemName: icon)
            //     .font(.system(size: 24))
            //     .frame(width: 80, height: 80, alignment: .center)
            //     .foregroundColor(.parachuteOrange)
            //     .padding(.top, -40)
            //     .zIndex(1)
        }
        // .padding(.horizontal)
        .frame(width: UIScreen.main.bounds.width)
        // .rr(color: .parachuteOrange)
        // .background(Material.ultraThinMaterial)
        // .cornerRadius(20)
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
        VStack(spacing: 0) {
            Spacer()
            HStack {
                Text("Let me...")
                    .font(.custom("SpaceMono-Regular", size: 32))
                    .foregroundColor(.parachuteLabel.opacity(0.8))
                    .padding(24)
                Spacer()
            }

            Spacer()

            FullWidthCard(icon: "goforward") {
                VStack {
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
                        Text(AttributedString(
                            markdown: "...**check** something for\n**\(quickSessionSecs) seconds**.",
                            boldFont: .custom("SpaceMono-Regular", size: 16).bold()
                        )
                        )
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                        .contentShape(Rectangle())
                    }
                    .tint(.parachuteOrange)
                    .buttonBorderShape(.roundedRectangle)
                    .font(.custom("SpaceMono-Regular", size: 16))
                    .buttonStyle(.dotted)
                    .rrGlow(color: .parachuteOrange, bg: .parachuteOrange)
                    .opacity(state.shouldShowShortSession ? 1 : 0)
                }
            }
            Spacer()
            FullWidthCard(icon: "arrow.up.arrow.down") {
                VStack {
                    // HStack {
                    //     Text("scroll...")
                    //         .font(.custom("SpaceMono-Regular", size: 32))
                    //         .foregroundColor(.parachuteLabel)
                    //         .padding(24)
                    //     Spacer()
                    // }
                    HStack {
                        let (before, after) = settingsStore.longSessionSecsAdjacentOptions

                        Spacer()

                        Button(action: {
                            if let before = before {
                                Task { @MainActor in
                                    settingsStore.settings.longSessionSecs = Int32(before)
                                    try await settingsController.syncSettings()
                                }
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.parachuteOrange)
                                // .padding(.horizontal, 10)
                                .padding(.vertical, 20)
                                .contentShape(Rectangle())
                        }
                        .padding(.trailing, 4)
                        .opacity(before != nil ? 1 : 0.2)

                        Spacer()

                        Button(action: {
                            Task { @MainActor in
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                ConnectedViewController.shared.set(state: .longSession)
                            }
                        }) {
                            Text(AttributedString(
                                markdown: "...**scroll** and relax for\n**\(longSessionMinutes) minutes**.",
                                boldFont: .custom("SpaceMono-Regular", size: 16).bold()
                            )
                            )
                            .foregroundColor(.parachuteOrange)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 20)
                            .contentShape(Rectangle())
                        }
                        .tint(.parachuteOrange)
                        .buttonBorderShape(.roundedRectangle)
                        .font(.custom("SpaceMono-Regular", size: 16))
                        .buttonStyle(.dotted)
                        .rrGlow(color: .parachuteOrange, bg: .parachuteOrange.opacity(0.3))
                        .opacity(state == .showLongSession ? 1 : 0)

                        Spacer()

                        Button(action: {
                            if let after = after {
                                Task { @MainActor in
                                    settingsStore.settings.longSessionSecs = Int32(after)
                                    try await settingsController.syncSettings()
                                }
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.parachuteOrange)
                                .padding(.vertical, 20)
                                .contentShape(Rectangle())
                        }
                        .opacity(after != nil ? 1 : 0.2)
                        Spacer()
                    }
                }
            }

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
