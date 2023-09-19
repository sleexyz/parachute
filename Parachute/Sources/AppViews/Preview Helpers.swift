//
//  File.swift
//  slowdown
//
//  Created by Sean Lee on 1/28/23.
//

import Controllers
import DI
import Foundation
import SwiftUI

public let previewDeps: [any Dep] = [
    VPNLifecycleManager.Provider(),
    SettingsController.Provider(),
    MockVPNConfigurationService.Provider(),
    SettingsStore.Provider(),
    OnboardingViewController.Provider(),
    ActivitiesHelper.Provider(),
    DeviceActivityController.Provider(),
    ActionController.Provider(),
]

public let connectedPreviewDeps: [any Dep] = {
    var value: [any Dep] = [
        ProfileManager.Provider(),
        ConnectedViewController.Provider(),
    ]
    value.append(contentsOf: previewDeps)
    return value
}()

public struct ConnectedPreviewContext<Content: View>: View {
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .provideDeps(connectedPreviewDeps)
            .environment(\.colorScheme, .dark)
            .preferredColorScheme(.dark)
    }
}
