
import Controllers
import SwiftUI

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
                // VPNConfigurationService.Provider(),
                FilterConfigurationService.Provider(),
                SettingsStore.Provider(),
                OnboardingViewController.Provider(),
                ActivitiesHelper.Provider(),
                DeviceActivityController.Provider(),
                ActionController.Provider(),
            ])
    }
}
