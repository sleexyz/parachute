import Controllers
import Models
import OSLog
import SwiftUI

public struct SimpleSelector: View {
    @EnvironmentObject private var settingsStore: SettingsStore
    @EnvironmentObject private var connectedViewController: ConnectedViewController
    @EnvironmentObject private var actionController: ActionController

    var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SimpleSelector")

    public init() {}

    public var body: some View {
        if case let .free(reason: reason) = settingsStore.settings.filterModeDecision {
            EmptyView()
        } else if !settingsStore.settings.isInScrollSession {
            ScrollSessionViewInner()
        } else {
            Button(action: {
                actionController.endSession()
            }) {
                HStack {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 24))
                    Spacer()
                    Text("End session")
                }
                .foregroundColor(.primary.opacity(0.8))
                .padding()
            }
            .tint(.secondary)
            .buttonStyle(.bordered)
            .font(.mainFont(size: 16))
        }
    }
}
