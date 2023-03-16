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
            name: "Casual",
            icon: "🏄",
            defaultPresetID: "casual_relax",
            presets: [
                "casual_focus",
                "casual_relax",
            ],
            color: .pink
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
            color: .indigo
        ),
        "sleep": Profile(
            id: "sleep",
            name: "Sleep",
            icon: "💤",
            defaultPresetID: "sleep_focus",
            presets: [
                "sleep_focus",
                "sleep_relax",
            ],
            color: .blue
        ),
    ]
}

extension Profile: Identifiable {
}
