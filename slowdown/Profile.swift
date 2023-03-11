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
    var name: String
    var icon: String
    var presets: OrderedSet<String>
    var color: Color
    
    var defaultPreset: Preset {
        Preset.presets[presets.elements[0]]!
    }
    
    static let profiles: OrderedDictionary<String, Profile> = [
        "detox": Profile(
            name: "Detox",
            icon: "🫧",
            presets: [
                "focus",
                "relax"
            ],
            color: .indigo.darker().darker()
//            color: AnyShapeStyle(.linearGradient(Gradient(colors: [.white, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
        ),
        "sleep": Profile(
            name: "Sleep",
            icon: "💤",
            presets: [
                "focus",
                "relax",
            ],
            color: .clear
        )
    ]
}
