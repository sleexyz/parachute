//
//  ProfileButton.swift
//  slowdown
//
//  Created by Sean Lee on 3/11/23.
//

import Foundation
import SwiftUI

struct ProfileButton: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var settingsStore: SettingsStore
    
    @Environment(\.namespace) var namespace: Namespace.ID
    
    var profile: Profile
    var profileID: String

    
    var isActive: Bool {
        profileID == settingsStore.settings.profileID
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 10) {
                Text(profile.icon)
                    .font(.largeTitle)
                Text(profile.name)
                    .font(.headline.weight(.regular))
            }
                .padding()
                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: CARD_PADDING))
                .overlay(RoundedRectangle(cornerRadius: CARD_PADDING, style: .continuous)
                    .stroke(.ultraThinMaterial)
                )
                .matchedGeometryEffect(id: profileID, in: namespace)
        }
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                if !profileManager.profileSelectorOpen {
                    profileManager.profileSelectorOpen = true
                    return
                }
                Task {
                    profileManager.presetSelectorOpen = false
                    profileManager.profileSelectorOpen = false
                    if !isActive {
                        try await profileManager.loadProfile(profileID: profileID)
//                        try await profileManager.loadOverlay(preset: preset, secs: preset.overlayTimeSecs)
                    }
                }
            }
    }
}
