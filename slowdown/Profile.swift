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
    var presets: OrderedSet<String>
    var color: Color
    
    var defaultPreset: Preset {
        Preset.presets[presets.elements[0]]!
    }
    
    static let profiles: OrderedDictionary<String, Profile> = [
        "detox": Profile(
            id: "detox",
            name: "Detox",
            icon: "🫧",
            presets: [
                "focus",
                "relax"
            ],
            color: .indigo.darker().darker()
        ),
        "sleep": Profile(
            id: "sleep",
            name: "Sleep",
            icon: "💤",
            presets: [
                "sleep_focus",
                "sleep_relax",
            ],
            color: .blue.darker(by: 0.5)
        )
    ]
}

extension Profile: Identifiable {
}
