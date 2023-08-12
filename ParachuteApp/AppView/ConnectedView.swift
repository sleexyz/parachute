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
    @EnvironmentObject var scrollSessionViewController: ScrollSessionViewController
    @EnvironmentObject var settingsStore: SettingsStore
    
    var body: some View {
        Group {
            if scrollSessionViewController.open {
                ScrollSessionView()
            } else {
                if #available(iOS 17.0, *) {
                    SlowdownWidgetView(settings: settingsStore.settings)
                        .padding()
                } else {
                    SimpleSelector()
                }
            }
        }
        .backgroundStyle(Color.parachuteBgDark)
    }
}

struct ConnectedViewDefaultPresetSelectorExpanded_Previews: PreviewProvider {
    static var previews: some View {
        ConnectedView()
            .consumeDep(ProfileManager.self) { value in
                value.presetSelectorOpen = true
            }
            .provideDeps(connectedPreviewDeps)
    }
}

struct ConnectedViewDefaultProfileSelectorExpanded_Previews: PreviewProvider {
    static var previews: some View {
        ConnectedView()
            .consumeDep(ProfileManager.self) { value in
                value.presetSelectorOpen = true
                value.profileSelectorOpen = true
            }
            .provideDeps(connectedPreviewDeps)
    }
}

struct ConnectedViewSlowing_Previews: PreviewProvider {
    static var previews: some View {
        ConnectedView()
            .consumeDep(StateController.self) { value in
                value.setState(value: Proxyservice_GetStateResponse.with {
                    $0.usagePoints = 12
                })
            }
            .provideDeps(connectedPreviewDeps)
    }
}
