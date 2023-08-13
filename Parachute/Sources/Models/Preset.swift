//
//  Preset.swift
//  slowdown
//
//  Created by Sean Lee on 2/27/23.
//

import Foundation
import ProxyService
import SwiftUI

public enum PresetType {
    case focus
    case relax
}

extension PresetType: Hashable {
    
}

public typealias PresetID = String

public struct Preset {
    public var name: String
    public var icon: String?
    public var type: PresetType
    public var description: String
    public var badgeText: String?
    public var presetData: Proxyservice_Preset
    public var mainColor: Color
    public var parentPreset: PresetID?
    public var overlayDurationSecs: Double?
    public var expandedBody: AnyView?
    public var childPresets: [PresetID] = []
    
    public init(name: String, icon: String? = nil, type: PresetType, description: String, badgeText: String? = nil, presetData: Proxyservice_Preset, mainColor: Color, parentPreset: PresetID? = nil, overlayDurationSecs: Double? = nil, expandedBody: AnyView? = nil, childPresets: [PresetID] = []) {
        self.name = name
        self.icon = icon
        self.type = type
        self.description = description
        self.badgeText = badgeText
        self.presetData = presetData
        self.mainColor = mainColor
        self.parentPreset = parentPreset
        self.overlayDurationSecs = overlayDurationSecs
        self.expandedBody = expandedBody
        self.childPresets = childPresets
    }
    
    
    public var id: String {
        presetData.id
    }
    public var scrollTimeLimit: Double {
        return self.presetData.usageMaxHp / 2
    }

    public static var quickBreak: Preset {
        Preset(
            name: "Scroll break",
            type: .relax,
            description: "Slowing disabled.",
            badgeText: "",
            presetData: .relax,
            mainColor: .blue,
            parentPreset: "focus",
            overlayDurationSecs: 10
        )
    }
    
    public static var scrollSession: Preset {
        Preset(
            name: "Scroll session",
            type: .relax,
            description: "Slowing disabled.",
            badgeText: "",
            presetData: .relax,
            mainColor: .blue,
            parentPreset: "focus",
            overlayDurationSecs: 5 * 60
        )
    }

    public static var focus: Preset {
        Preset(
            name: "Active",
            icon: "🫧",
            type: .focus,
            description: "Slowing down content...",
            badgeText: "∞",
            presetData: .focus,
            mainColor: .blue,
            childPresets: [
                "relax"
            ]
        )
    }
}

public extension Proxyservice_Preset {
    static var focus: Proxyservice_Preset {
        Proxyservice_Preset.with {
            $0.id = "focus"
            $0.baseRxSpeedTarget = 40e3
            $0.mode = .focus
        }
    }

    static var relax: Proxyservice_Preset {
        Proxyservice_Preset.with {
            $0.id = "relax"
            $0.baseRxSpeedTarget = .infinity
            $0.mode = .focus
        }
    }
}

