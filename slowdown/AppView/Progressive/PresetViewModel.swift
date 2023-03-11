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
    @Binding var presetData: Proxyservice_Preset
    
    var preset: Preset
    
    var scrollTimeLimit: Binding<Double> {
        Binding {
            return self.presetData.usageMaxHp / 2
        } set: {
            self.presetData.usageMaxHp = $0 * 2
        }
    }
    
    var restTime: Binding<Double> {
        Binding {
            return self.presetData.usageMaxHp / 2 / self.presetData.usageHealRate
        } set: {
            self.presetData.usageHealRate = self.presetData.usageMaxHp / 2 / $0
        }
    }
    
    var level: Double {
        return scrollTimeLimit.wrappedValue
            .applyMapping(Mapping(a: 10, b: 0, c: 0, d: 3, clip: true))
    }
    
    var mainColor: Color {
        preset.mainColor
//        if let color = preset.mainColor {
//            return color
//        }
//        let h: Double = 259/360
//        let s = level.applyMapping(Mapping(a: 0, b: 3, c: 0.2, d: 1, outWarp: .linear))
//        let b = level.applyMapping(Mapping(a: 0, b: 3, c: 0.67, d: 0.4, outWarp: .linear))
//        return Color(hue: h, saturation: s, brightness: b)
    }
}
