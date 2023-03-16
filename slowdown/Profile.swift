//
//  Profile.swift
//  slowdown
//
//  Created by Sean Lee on 3/10/23.
//

import Foundation
import OrderedCollections
import ProxyService
import SwiftUI

struct Profile {
    var id: String
    var name: String
    var icon: String
    var defaultPresetID: String
    var presets: OrderedSet<String>
    var color: Color
    
    var defaultPreset: Preset {
        Preset.presets[defaultPresetID]!
    }
    
    static let profiles: OrderedDictionary<String, Profile> = [
        "casual": Profile(
            id: "casual",
            name: "Glide",
            icon: "🪂",
            defaultPresetID: "casual",
            presets: [
                "casual",
                "supercasual",
                "ultracasual",
            ],
            color: .red.darker()
        ),
        "detox": Profile(
            id: "detox",
            name: "Detox",
            icon: "🫧",
            defaultPresetID: "focus",
            presets: [
                "focus",
                "relax"
            ],
            color: .indigo.lighter().lighter()
        ),
        "unplug": Profile(
            id: "unplug",
            name: "Unplug",
            icon: "🌌",
            defaultPresetID: "unplug",
            presets: [
                "unplug",
                "unplug_break",
            ],
            color: .blue
        ),
    ]
}

extension Profile: Identifiable {
}
