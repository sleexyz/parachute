//
//  ConnectedView.swift
//  slowdown
//
//  Created by Sean Lee on 2/15/23.
//

import Foundation
import SwiftUI
import ProxyService
import OrderedCollections
import Controllers
import AppViews
import CommonViews

struct ProfileCardModifier: ViewModifier {
    @EnvironmentObject var profileManager: ProfileManager
    
    func body(content: Content) -> some View {
        content
    }
}

struct ConnectedView: View {
    @EnvironmentObject var connectedViewController: ConnectedViewController
    
    var body: some View {
        Group {
            switch connectedViewController.state {
            case .settings, .main, .scrollSession:
                MainView()
                    .transition(.opacity)
            case .longSession:
                LongSessionView()
                    .transition(.opacity)
            }
        }
        .background(LinearGradient.bg)
    }
}

struct ConnectedView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectedPreviewContext {
            ConnectedView()
        }
    }
}

struct ConnectedViewSession_Previews: PreviewProvider {
    static var previews: some View {
        ConnectedPreviewContext {
            ConnectedView()
                .consumeDep(ProfileManager.self) { profileManager in
                    Task { @MainActor in
                        try await profileManager.loadPreset(
                            preset: .focus,
                            overlay: .quickBreak
                        )
                    }
                }
        }
    }
}


struct ConnectedViewScroll_Previews: PreviewProvider {
    static var previews: some View {
        ConnectedPreviewContext {
            ConnectedView()
                .consumeDep(ConnectedViewController.self) { connectedViewController in
                    connectedViewController.set(state: .scrollSession)
                }
        }
    }
}
