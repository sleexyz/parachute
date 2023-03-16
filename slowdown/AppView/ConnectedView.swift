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


struct ProfileCardModifier: ViewModifier {
    @EnvironmentObject var profileManager: ProfileManager
    
    func body(content: Content) -> some View {
        content
    }
}

struct ConnectedView: View {
    @EnvironmentObject var vpnLifecycleManager: VPNLifecycleManager
    @EnvironmentObject var service: VPNConfigurationService
    @EnvironmentObject var stateController: StateController
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var profileManager: ProfileManager
    
    @Namespace var namespace
    
    var body: some View {
        ZStack(alignment: .top) {
            if !profileManager.profileSelectorOpen {
                ProfileCard(
                    profile: profileManager.activeProfile,
//                    height: UIScreen.main.bounds.height - PROFILE_CARD_HEIGHT * 2
//                    height: UIScreen.main.bounds.height,
                    height: 40,
                    color: profileManager.activeProfile.color.opacity(0.02)
//                    height: PROFILE_CARD_HEIGHT
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .offset(y: 60)
                .zIndex(3)
                .animation(profileManager.state.animation, value: profileManager.profileSelectorOpen)
            }
            PresetSelector(shouldRender: !profileManager.profileSelectorOpen)
                .environment(\.activeStackPosition, .bottom)
                .environment(\.closedStackPosition, .belowbelow)
                .zIndex(2)
            
            if !profileManager.profileSelectorOpen && !profileManager.presetSelectorOpen {
                PresetContent()
                    .padding(.top, PROFILE_CARD_HEIGHT)
                    .frame(height: UIScreen.main.bounds.height, alignment: .top)
                    .animation(nil, value: profileManager.profileSelectorOpen)
                    .zIndex(0)
                    .transition(AnyTransition.asymmetric(
                        insertion: .opacity.animation(profileManager.state.animation.delay(ANIMATION_SECS )),
                        removal: .opacity.animation(profileManager.state.animation)
                    ))
            }
            
            ProfileSelector()
                .zIndex(3)
        }
        .animation(profileManager.state.animation, value: profileManager.profileSelectorOpen)
        .namespace(namespace)
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
