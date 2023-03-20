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
    var icon: String?
    var type: PresetType
    var description: String
    var badgeText: String?
    var presetData: Proxyservice_Preset
    var mainColor: Color
    var overlayDurationSecs: Double?
    
    var id: String {
        presetData.id
    }
    var scrollTimeLimit: Double {
        return self.presetData.usageMaxHp / 2
    }
    
    static let presets: OrderedDictionary<String, Preset> = [
        "focus": Preset(
            name: "Detox",
            icon: "🫧",
            type: .focus,
            description: "Slows content down to dial-up speeds",
            badgeText: "∞",
            presetData: Proxyservice_Preset.with {
                $0.id = "focus"
                $0.baseRxSpeedTarget = 40e3
                $0.mode = .focus
            },
            mainColor: Profile.profiles["detox"]!.color.opacity(0.6)
        ),
        "relax": Preset(
            name: "Break",
            type: .relax,
            description: "Temporarily disable slowing",
            badgeText: "3 min",
            presetData: Proxyservice_Preset.with {
                $0.id = "relax"
                $0.baseRxSpeedTarget = .infinity
                $0.mode = .focus
            },
            mainColor: Profile.profiles["detox"]!.color.opacity(0.3),
            overlayDurationSecs: 3 * 60
        ),
        "unplug": Preset(
            name: "Sleep",
            icon: "🌌",
            type: .focus,
            description: "Slows all internet down to dial-up speeds",
            badgeText: "∞",
            presetData: Proxyservice_Preset.with {
                $0.id = "unplug"
                $0.baseRxSpeedTarget = 40e3
                $0.mode = .focus
                $0.trafficRules = Proxyservice_TrafficRules.with {
                    $0.matchAllTraffic = true
                }
            },
            mainColor: Profile.profiles["unplug"]!.color.opacity(0.6)
        ),
        "unplug_break": Preset(
            name: "Break",
            type: .relax,
            description: "Temporarily disable slowing",
            badgeText: "1 min",
            presetData: Proxyservice_Preset.with {
                $0.id = "unplug_break"
                $0.baseRxSpeedTarget = .infinity
                $0.mode = .focus
                $0.trafficRules = Proxyservice_TrafficRules.with {
                    $0.matchAllTraffic = true
                }
            },
            mainColor: Profile.profiles["unplug"]!.color.opacity(0.3),
            overlayDurationSecs: 1 * 60
        ),
        "casual": Preset(
            name: "2 minutes",
            icon: "🪂",
            type: .relax,
            description: "Gradually slow down content at the end of 2 minutes of usage",
            badgeText: "∞",
            presetData: Proxyservice_Preset.with {
                $0.id = "casual"
                $0.usageMaxHp = 2
                $0.usageHealRate = 0
                $0.mode = .progressive
            },
            mainColor: Profile.profiles["casual"]!.color.opacity(1)
        ),
        "supercasual": Preset(
            name: "5 minutes",
            icon: "🪂",
            type: .relax,
            description: "Gradually slow down content at the end of 5 minutes of usage",
            badgeText: "∞",
            presetData: Proxyservice_Preset.with {
                $0.id = "supercasual"
                $0.usageMaxHp = 5
                $0.usageHealRate = 0
                $0.mode = .progressive
            },
            mainColor: Profile.profiles["casual"]!.color.opacity(0.7)
        ),
        "ultracasual": Preset(
            name: "10 minutes",
            icon: "🪂",
            type: .relax,
            description: "Gradually slow down content at the end of 10 minutes of usage",
            badgeText: "∞",
            presetData: Proxyservice_Preset.with {
                $0.id = "ultracasual"
                $0.usageMaxHp = 10
                $0.usageHealRate = 0
                $0.mode = .progressive
            },
            mainColor: Profile.profiles["casual"]!.color.opacity(0.5)
        ),
    ]

}

