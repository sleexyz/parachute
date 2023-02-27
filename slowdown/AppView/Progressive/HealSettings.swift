//
//  HealSettings.swift
//  slowdown
//
//  Created by Sean Lee on 2/20/23.
//

import Foundation
import SwiftUI

struct HealSettings: View {
    @EnvironmentObject var controller: SettingsController
    var model: PresetViewModel
    
    @FocusState private var scrollTimeFocused: Bool
    @FocusState private var restTimeFocused: Bool
    
    
    private var baselineSpeedEnabled: Binding<Bool> {
        Binding {
            return model.presetData.usageBaseRxSpeedTarget != 0.0
        } set: {
            if $0 {
                model.presetData.usageBaseRxSpeedTarget = 1e6
            } else {
                model.presetData.usageBaseRxSpeedTarget = 0
            }
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Scroll time")
                TextField("Scroll time (min)", value: model.scrollTimeLimit, format: .number)
                    .focused($scrollTimeFocused)
                    .textFieldStyle(.roundedBorder)
                    .foregroundColor(nil)
                    .padding()
                    .removeFocusOnTap(enabled: scrollTimeFocused)
                    .onChange(of: model.scrollTimeLimit.wrappedValue) { _ in
                        controller.syncSettings()
                    }
            }
            HStack {
                Text("Rest time")
                TextField("Rest time", value: model.restTime, format: .number)
                    .focused($restTimeFocused)
                    .textFieldStyle(.roundedBorder)
                    .foregroundColor(nil)
                    .padding()
                    .removeFocusOnTap(enabled: restTimeFocused)
                    .onChange(of: model.restTime.wrappedValue) { _ in
                        controller.syncSettings()
                    }
            }
            VStack {
                Toggle("Set max speed", isOn: baselineSpeedEnabled)
                    .onChange(of: baselineSpeedEnabled.wrappedValue) { _ in
                        controller.syncSettings()
                    }
                    .tint(.purple)
                if baselineSpeedEnabled.wrappedValue {
                    SpeedBar(speed: model.$presetData.usageBaseRxSpeedTarget, minSpeed: 40e3, maxSpeed: 10e6) {
                        controller.syncSettings()
                    }
                    .tint(.purple)
                }
            }
        }
    }
}

