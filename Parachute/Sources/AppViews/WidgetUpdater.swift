import SwiftUI
import Controllers
import Combine
import WidgetKit
import OSLog

public struct WidgetUpdater<Inner: View>: View {
    @ViewBuilder var content: () -> Inner
    @EnvironmentObject var store: SettingsStore

    @State var bag = Set<AnyCancellable>()

    var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "WidgetUpdater")

    public init(@ViewBuilder content: @escaping () -> Inner) {
        self.content = content
    }
    
    public var body: some View {
        content()
            .onAppear {
                store.$savedSettings.dropFirst().sink { settings in
                    WidgetCenter.shared.reloadAllTimelines()
                    logger.info("reloaded widgets")
                }.store(in: &bag)
            }
    }
}

