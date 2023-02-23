//
//  FocusCard.swift
//  slowdown
//
//  Created by Sean Lee on 2/23/23.
//

import Foundation
import SwiftUI

struct FocusCard<Content: View>: View {
    var model: PresetViewModel
    
    @ViewBuilder
    var content: () -> Content
    
    var body: some View {
        Card(
            title: model.preset.name,
            caption: "Disallows scrolling",
            backgroundColor: model.mainColor
        ) {
            content()
        }
    }
}
