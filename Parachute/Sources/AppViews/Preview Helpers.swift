//
//  File.swift
//  slowdown
//
//  Created by Sean Lee on 1/28/23.
//

import Foundation
import SwiftUI
import DI
import Controllers                    

public let previewDeps : [any Dep] = [
    VPNLifecycleManager.Provider(),
    SettingsController.Provider(),
    MockVPNConfigurationService.Provider(),
    SettingsStore.Provider()
]

public let connectedPreviewDeps : [any Dep] = {
    var value: [any Dep] = [
        ProfileManager.Provider(),
        ConnectedViewController.Provider()
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
