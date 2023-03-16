//
//  ProfileSelector.swift
//  slowdown
//
//  Created by Sean Lee on 3/11/23.
//

import Foundation
import SwiftUI


struct ProfileSelector: View {
    @EnvironmentObject var profileManager: ProfileManager
    
    var height: Double {
        UIScreen.main.bounds.height
    }
    
    func transition(profile: Profile) -> AnyTransition {
        if profile.id == profileManager.activeProfileID {
            return .identity
        }
        return .opacity.animation(profileManager.state.animation.delay(ANIMATION_SECS))
    }
    var body: some View {
        VStack(spacing: 60) {
            ForEach(Profile.profiles.elements, id: \.key) { entry in
                let profile = entry.value
                
                if profileManager.profileSelectorOpen {
                    if profile.id == profileManager.activeProfileID {
                        ProfileButton(
                            profile: profile
                        )
                        .padding()
                    } else {
                        ProfileButton(
                            profile: profile
                        )
                            .transition(.asymmetric(
                                insertion: .opacity.animation(profileManager.state.animation.delay(ANIMATION_SECS)),
                                removal: .opacity.animation(profileManager.state.animation)
                            ))
                            .padding()
                        
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapBackground(enabled: profileManager.profileSelectorOpen) {
            withAnimation {
                profileManager.profileSelectorOpen = false
            }
        }
        .background(.ultraThinMaterial.opacity(profileManager.profileSelectorOpen ? 1 : 0))
        .animation(profileManager.state.animation, value: profileManager.profileSelectorOpen)
    }
}
