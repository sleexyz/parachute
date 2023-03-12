//
//  ProfileCard.swift
//  slowdown
//
//  Created by Sean Lee on 3/11/23.
//

import Foundation
import SwiftUI

let PROFILE_CARD_HEIGHT: Double = 180

struct ProfileCard: View {
    @EnvironmentObject var profileManager: ProfileManager
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.namespace) var namespace: Namespace.ID
    
    
    var profile: Profile
    
    var isActive: Bool {
        profile.id == profileManager.activeProfileID
    }
    
    var height: Double
    
    var color: Color
    var stroke: Bool = false
    
    var body: some View {
            HStack(alignment: .center, spacing: 10) {
                Text(profile.icon)
                    .font(.largeTitle)
                Text(profile.name)
                    .font(.title)
            }
            .foregroundColor(color.getForegroundColor(colorScheme))
            .padding()
            .frame(maxWidth: .infinity, minHeight: height, alignment: .bottomLeading)
            .background(color)
//            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: CARD_PADDING))
            .overlay(RoundedRectangle(cornerRadius: CARD_PADDING, style: .continuous)
                .stroke(.ultraThinMaterial)
                .opacity(stroke ? 1 : 0)
            )
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                if !profileManager.profileSelectorOpen {
                    profileManager.profileSelectorOpen = true
                    return
                }
                withAnimation {
                    profileManager.presetSelectorOpen = false
                    profileManager.profileSelectorOpen = false
                    if !isActive {
                      profileManager.loadProfile(profileID: profile.id)
                    }
                }
            }
            .matchedGeometryEffect(id: profile.id, in: namespace)
//            .frame(minHeight: 200)
//            .background(.pink.opacity(1))
    }
    
}


struct ProfileButton: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var settingsStore: SettingsStore
    
    @Environment(\.namespace) var namespace: Namespace.ID
    
    var profile: Profile

    
    var isActive: Bool {
        profile.id == settingsStore.settings.profileID
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
                .matchedGeometryEffect(id: profile.id, in: namespace)
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
                        try await profileManager.loadProfile(profileID: profile.id)
//                        try await profileManager.loadOverlay(preset: preset, secs: preset.overlayTimeSecs)
                    }
                }
            }
    }
}
