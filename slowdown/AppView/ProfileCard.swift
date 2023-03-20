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
    
    var height: Double = 40
    
    var color: Color {
        profile.color.opacity(0.02)
    }
    var stroke: Bool = true
    
    var body: some View {
            HStack(alignment: .center, spacing: 20) {
                Text(profile.icon)
                    .font(.largeTitle)
                Text(profile.name)
                    .font(.title)
                    .padding(.trailing, 30)
            }
            .foregroundColor(color.bakeAlpha(colorScheme).getForegroundColor())
//            .foregroundColor(isActive ? color : color.getForegroundColor(colorScheme))
            .padding()
            .padding()
//            .frame(maxWidth: .infinity, minHeight: height, alignment: .bottomLeading)
            .frame(minHeight: height, alignment: .bottomLeading)
            .background(color)
            .background(.ultraThinMaterial
                .opacity(stroke ? 1 : 0))
            .clipShape(RoundedRectangle(cornerRadius: CARD_PADDING * 2))
            .overlay(RoundedRectangle(cornerRadius: CARD_PADDING * 2, style: .continuous)
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
//                    if !isActive {
                      profileManager.loadProfile(profileID: profile.id)
//                    }
                }
            }
            .matchedGeometryEffect(id: "profile_" + profile.id, in: namespace)
    }
    
}

struct ProfileHeader: View {
    @EnvironmentObject var profileManager: ProfileManager
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.namespace) var namespace: Namespace.ID
    
    
    var profile: Profile
    
    var body: some View {
            HStack(alignment: .center, spacing: 20) {
                Text(profile.icon)
                    .font(.largeTitle)
                Text(profile.name)
                    .font(.largeTitle.weight(.thin))
                    .padding(.trailing, 30)
            }
            .foregroundColor(.clear.getForegroundColor())
            .padding()
            .padding()
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
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            withAnimation {
                if !profileManager.profileSelectorOpen {
                    profileManager.profileSelectorOpen = true
                    return
                }
                profileManager.presetSelectorOpen = false
                profileManager.profileSelectorOpen = false
//                if !isActive {
                    profileManager.loadProfile(profileID: profile.id)
//                }
            }
        }
        .matchedGeometryEffect(id: "profile_" + profile.id, in: namespace)
    }
}
