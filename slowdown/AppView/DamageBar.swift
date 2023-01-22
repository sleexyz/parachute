//
//  DamageBar.swift
//  slowdown
//
//  Created by Sean Lee on 1/7/23.
//

import Foundation
import SwiftUI


struct DamageBar: View {
    var damage: Double
    var maxHP: Double
    var currentHP: Double {
        return max(maxHP - damage, 0)
    }
    var ratio: Double {
        return currentHP / maxHP
    }
    
    var height: Double = 20
    
    var color: Color {
        if ratio < 0.33 {
            return .red
        }
        if ratio < 0.5 {
            return .yellow
        }
        return .green
    }
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 100, style: .continuous)
                    .fill(color)
                    .frame(width: geometry.size.width * ratio, height: height)
                RoundedRectangle(cornerRadius: 100, style: .continuous)
                    .fill(color)
                    .opacity(0.1)
                    .frame(width: geometry.size.width, height: height)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: height)
    }
}

struct DamageBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            DamageBar(damage: 0, maxHP: 6)
            DamageBar(damage: 1, maxHP: 6)
            DamageBar(damage: 2, maxHP: 6)
            DamageBar(damage: 3, maxHP: 6)
            DamageBar(damage: 4, maxHP: 6)
            DamageBar(damage: 5, maxHP: 6)
            DamageBar(damage: 6, maxHP: 6)
        }
    }
}
