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
import AppViews

let previewDeps : [any Dep] = [
    VPNLifecycleManager.Provider(),
    SettingsController.Provider(),
    MockVPNConfigurationService.Provider(),
    SettingsStore.Provider()
]

let connectedPreviewDeps : [any Dep] = {
    var value: [any Dep] = [
        ProfileManager.Provider(),
        StateController.Provider(),
        ScrollSessionViewController.Provider()
    ]
    value.append(contentsOf: previewDeps)
    return value
}()


struct ConnectedPreviewContext<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .provideDeps(connectedPreviewDeps)
            .environment(\.colorScheme, .dark)
            .preferredColorScheme(.dark)
    }
}
