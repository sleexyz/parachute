//
//  Preset.swift
//  slowdown
//
//  Created by Sean Lee on 2/27/23.
//

import Foundation
import ProxyService
import SwiftUI
import OrderedCollections

struct Preset {
    var name: String
    var presetData: Proxyservice_Preset
    var mainColor: Color
    var opacity: Double
    
    var overlayTimeSecs: Double {
        if presetData.mode == .progressive {
            return presetData.usageMaxHp * 60
        }
        return 10 * 60
    }
    var id: String {
        presetData.id
    }
    var scrollTimeLimit: Double {
        return self.presetData.usageMaxHp / 2
    }
    
    static let presets: OrderedDictionary<String, Preset> = [
        // Default preset
        "focus": Preset(
            name: "Disconnect",
            presetData: Proxyservice_Preset.with {
                $0.id = "focus"
                $0.baseRxSpeedTarget = 40e3
                $0.mode = .focus
            },
//            mainColor: .purple.darker().darker().opacity(0.5)
            mainColor: Profile.profiles["detox"]!.color.opacity(0.7),
            opacity: 1
        ),
        "relax": Preset(
            name: "Connect",
            presetData: Proxyservice_Preset.with {
                $0.id = "relax"
                $0.usageMaxHp = 8
                $0.usageHealRate = 0.5
                $0.mode = .progressive
            },
//            mainColor: .red.opacity(0.5)
            mainColor: Profile.profiles["detox"]!.color.opacity(0.2),
            opacity: 1
//            mainColor: Color(red: 0.19, green: 0.14, blue: 0.38).lighter(by: 0.4)
        ),
    ]

}

