//
//  HealButton.swift
//  slowdown
//
//  Created by Sean Lee on 2/13/23.
//

import Foundation
import SwiftUI

struct HealButton: View {
    var disabledOverride: Bool
    
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var stateController: StateController

    var body: some View {
        let disabled = disabledOverride || !stateController.isSlowing
        let opacity = disabled ? 0.5 : 1
        Button("Scroll more") {
                stateController.heal()
            }
        .font(.system(.body))
        .padding()
        .foregroundColor(Color.white)
        .background(Color.accentColor.grayscale(1))
        .clipShape(RoundedRectangle(cornerRadius: 10, style:.continuous))
        .opacity(opacity)
        .disabled(disabled)
        .onTapGesture {
        }
        
    }
}

struct LockedHealButton: View {
    var body: some View {
        TimerLock { timeLeft in
            ZStack (alignment: .topTrailing) {
                HealButton(disabledOverride: timeLeft > 0)
                if timeLeft > 0 {
                    TimerLockBadge(timeLeft: timeLeft)
                        .offset(x: 25, y:-18)
                }
            }
        }
        
    }
    
}


struct LockedHealButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            LockedHealButton()
                .provideDeps(connectedPreviewDeps)
            Spacer()
        }
    }
}
