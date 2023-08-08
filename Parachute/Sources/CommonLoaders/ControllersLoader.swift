
import SwiftUI
import Controllers

public struct ControllersLoader<Inner: View>: View {
    @ViewBuilder var content: () -> Inner

    public init(@ViewBuilder content: @escaping () -> Inner) {
        self.content = content
    }
    
    public var body: some View {
        content()
            .provideDeps([
                ProfileManager.Provider(),
                VPNLifecycleManager.Provider(),
                SettingsController.Provider(),
                VPNConfigurationService.Provider(),
                SettingsStore.Provider()
            ])
    }
}

