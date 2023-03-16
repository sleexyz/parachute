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

enum PresetType {
    case focus
    case relax
}

extension PresetType: Hashable {
    
}

struct Preset {
    var name: String
    var type: PresetType
    var description: String
    var presetData: Proxyservice_Preset
    var mainColor: Color
    var opacity: Double
    var overlayDurationSecs: Double?
    
    var id: String {
        presetData.id
    }
    var scrollTimeLimit: Double {
        return self.presetData.usageMaxHp / 2
    }
    
    static let presets: OrderedDictionary<String, Preset> = [
        "focus": Preset(
            name: "Tune out",
            type: .focus,
            description: "Slow down social media",
            presetData: Proxyservice_Preset.with {
                $0.id = "focus"
                $0.baseRxSpeedTarget = 40e3
                $0.mode = .focus
            },
            mainColor: Profile.profiles["detox"]!.color.opacity(0.6),
            opacity: 0
        ),
        "relax": Preset(
            name: "Tune in",
            type: .relax,
            description: "Allow 4 minutes of social media",
            presetData: Proxyservice_Preset.with {
                $0.id = "relax"
                $0.baseRxSpeedTarget = .infinity
                $0.mode = .focus
            },
            mainColor: Profile.profiles["detox"]!.color.opacity(0.3),
            opacity: 0.5,
            overlayDurationSecs: 4 * 60
        ),
        "sleep_focus": Preset(
            name: "Tune out",
            type: .focus,
            description: "Slow down all internet",
            presetData: Proxyservice_Preset.with {
                $0.id = "sleep_focus"
                $0.baseRxSpeedTarget = 40e3
                $0.mode = .focus
                $0.trafficRules = Proxyservice_TrafficRules.with {
                    $0.matchAllTraffic = true
                }
            },
            mainColor: Profile.profiles["sleep"]!.color.opacity(0.6),
            opacity: 0
        ),
        "sleep_relax": Preset(
            name: "Tune in",
            type: .relax,
            description: "Allow 1 minute of internet use",
            presetData: Proxyservice_Preset.with {
                $0.id = "sleep_relax"
                $0.baseRxSpeedTarget = .infinity
                $0.mode = .focus
                $0.trafficRules = Proxyservice_TrafficRules.with {
                    $0.matchAllTraffic = true
                }
            },
            mainColor: Profile.profiles["sleep"]!.color.opacity(0.3),
            opacity: 0.5,
            overlayDurationSecs: 1 * 60
        ),
        "casual_focus": Preset(
            name: "Tune out",
            type: .focus,
            description: "Slow down social media for 10 minutes",
            presetData: Proxyservice_Preset.with {
                $0.id = "casual_focus"
                $0.baseRxSpeedTarget = 40e3
                $0.mode = .focus
            },
            mainColor: Profile.profiles["casual"]!.color.opacity(0.6),
            opacity: 0,
            overlayDurationSecs: 10 * 60
        ),
        "casual_relax": Preset(
            name: "Tune in",
            type: .relax,
            description: "Allow 10 minutes of social media",
            presetData: Proxyservice_Preset.with {
                $0.id = "casual_relax"
                $0.usageMaxHp = 10
                $0.usageHealRate = 0
                $0.mode = .progressive
            },
            mainColor: Profile.profiles["casual"]!.color.opacity(0.3),
            opacity: 0.5
        ),
    ]

}

