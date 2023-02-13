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
        Button("Extend session") {
                stateController.heal()
            }
        .font(.system(.body))
        .padding()
        .foregroundColor(Color.white)
        .background(Color.accentColor.grayscale(1))
        .clipShape(RoundedRectangle(cornerRadius: 100, style:.continuous))
        .opacity(opacity)
        .disabled(disabled)
        .onTapGesture {
        }
        
    }
}
