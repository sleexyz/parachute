import Controllers
import Models
import OSLog
import SwiftUI

public struct SimpleSelector: View {
    @EnvironmentObject private var profileManager: ProfileManager
    @EnvironmentObject private var settingsStore: SettingsStore
    @EnvironmentObject private var connectedViewController: ConnectedViewController

    var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SimpleSelector")

    public init() {}

    public var body: some View {
        if !settingsStore.settings.isInScrollSession {
            Button(action: {
                Task { @MainActor in
                    connectedViewController.set(state: .scrollSession)
                }
            }) {
                HStack {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 24))
                    Spacer()
                    Text("SCROLL")
                }
                .foregroundColor(.parachuteOrange)
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .contentShape(Rectangle())
            }
            .frame(width: UIScreen.main.bounds.width / 2)
            .tint(.parachuteOrange)
            .buttonBorderShape(.roundedRectangle)
            .font(.custom("SpaceMono-Regular", size: 16))
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(style: StrokeStyle(lineWidth: 1))
                    .foregroundColor(.parachuteOrange.opacity(0.2)))
            .glow(color: .parachuteOrange.opacity(0.3), radius: 54)

            // .buttonStyle(.dotted)
            // .rrGlow(color: .parachuteOrange, bg: .clear)

        } else {
            Button(action: {
                Task { @MainActor in
                    try await profileManager.endSession()
                }
            }) {
                HStack {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 24))
                    Spacer()
                    Text("END SESSION")
                }
                .foregroundColor(.primary.opacity(0.8))
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .contentShape(Rectangle())
            }
            .frame(width: UIScreen.main.bounds.width / 1.5)
            .tint(.primary)
            .buttonBorderShape(.roundedRectangle)
            .font(.custom("SpaceMono-Regular", size: 16))
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(style: StrokeStyle(lineWidth: 1))
                    .foregroundColor(.primary.opacity(0.2)))
            .glow(color: .primary.opacity(0.3), radius: 54)
        }
    }
}
