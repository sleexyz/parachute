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
//            if !profileManager.profileSelectorOpen {
//            ProfileHeader(
//                profile: profileManager.activeProfile
//            )
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .offset(y: 60)
//            .zIndex(0)
//            .animation(ANIMATION, value: profileManager.profileSelectorOpen)
//            }
            
            PresetSelector(shouldRender: profileManager.presetSelectorOpen)
                .zIndex(2)
            if !profileManager.profileSelectorOpen && !profileManager.presetSelectorOpen {
                PresetContent()
                    .id(profileManager.activePreset.id)
                //                        .padding(.top, PROFILE_CARD_HEIGHT)
                //                        .frame(height: UIScreen.main.bounds.height, alignment: .top)
                    .animation(nil, value: profileManager.profileSelectorOpen)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .zIndex(2)
                    .transition(AnyTransition.asymmetric(
                        insertion: .opacity.animation(ANIMATION.delay(ANIMATION_SECS * 3 )),
                        removal: .opacity.animation(ANIMATION)
                    ))
            }
            
            SelectedPreset(shouldRender: !profileManager.profileSelectorOpen && !profileManager.presetSelectorOpen)
                .animation(ANIMATION.delay(ANIMATION_SECS), value: profileManager.presetSelectorOpen)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .zIndex(2)
            
            ProfileSelector()
                .zIndex(3)
        }
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
