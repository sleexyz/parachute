//
//  PresetViewModel.swift
//  slowdown
//
//  Created by Sean Lee on 2/19/23.
//

import Foundation
import SwiftUI
import ProxyService
import Combine
import Logging

struct PresetViewModel {
    @Binding var preset: Proxyservice_Preset
    
    var scrollTimeLimit: Binding<Double> {
        Binding {
            return self.preset.usageMaxHp / 2
        } set: {
            self.preset.usageMaxHp = $0 * 2
        }
    }
    
    var restTime: Binding<Double> {
        Binding {
            return self.preset.usageMaxHp / 2 / self.preset.usageHealRate
        } set: {
            self.preset.usageHealRate = self.preset.usageMaxHp / 2 / $0
        }
    }
    
    var level: Double {
        return scrollTimeLimit.wrappedValue
            .applyMapping(Mapping(a: 10, b: 0, c: 0, d: 3, clip: true))
    }
    
    var mainColor: Color {
        let h: Double = 259/360
        let s = level.applyMapping(Mapping(a: 0, b: 3, c: 0.2, d: 1, outWarp: .linear))
        let b = level.applyMapping(Mapping(a: 0, b: 3, c: 0.67, d: 0.4, outWarp: .linear))
        return Color(hue: h, saturation: s, brightness: b)
    }
}
