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
    var expandedBody: AnyView?
    var childPresets: [PresetID] = []
    
    var id: String {
        presetData.id
    }
    var scrollTimeLimit: Double {
        return self.presetData.usageMaxHp / 2
    }
}

