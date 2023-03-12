//
//  ProfileSelector.swift
//  slowdown
//
//  Created by Sean Lee on 3/11/23.
//

import Foundation
import SwiftUI

var ANIMATION_SECS = 0.2

struct ProfileSelector: View {
    @EnvironmentObject var profileManager: ProfileManager
    
    var height: Double {
        UIScreen.main.bounds.height
    }
    
    var body: some View {
        VStack {
            ForEach(Profile.profiles.elements, id: \.key) { entry in
                let profile = entry.value
                let profileID = entry.key
                
                if profileManager.profileSelectorOpen {
                    ProfileButton(profile: profile, profileID: profileID)
                        .padding(30)
                        .transition(
                            profileID == profileManager.activeProfileID
                            ? AnyTransition.opacity.animation(profileManager.state.animation.delay(0))
                            : AnyTransition.opacity.animation(profileManager.state.animation.delay(ANIMATION_SECS)))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapBackground(enabled: profileManager.profileSelectorOpen) {
            profileManager.profileSelectorOpen = false
        }
        .background(.ultraThinMaterial)
//        .background(.ultraThinMaterial.opacity(profileManager.profileSelectorOpen ? 1 : 0))
        .opacity(profileManager.profileSelectorOpen ? 1 : 0)
        .transition(AnyTransition.opacity.animation(profileManager.state.animation))
        .animation(profileManager.state.animation, value: profileManager.profileSelectorOpen)
    }
}
