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
}

