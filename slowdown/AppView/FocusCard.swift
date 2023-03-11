//
//  FocusCard.swift
//  slowdown
//
//  Created by Sean Lee on 2/23/23.
//

import Foundation
import SwiftUI

struct FocusCard<Content: View>: View {
    var preset: Preset
    
    @ViewBuilder
    var content: () -> Content
    
    var body: some View {
        Card(
            title: preset.name,
            caption: "Disallows scrolling",
            backgroundColor: preset.mainColor,
            material: .thinMaterial.opacity(preset.opacity)
        ) {
            content()
        }
    }
}
