//
//  DamageBar.swift
//  slowdown
//
//  Created by Sean Lee on 1/7/23.
//

import Foundation
import SwiftUI


struct DamageBar: View {
    var ratio:Double
    
    var slowAmount: Double = 0
    
    var height: Double = 20
    
    var color: Color {
        if 1 - slowAmount <= 0.33 {
            return .red
        }
        if 1 - slowAmount <= 0.5 {
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

struct StagedDamageBar: View {
    var ratio: Double
    var slowAmount: Double
    var height: Double = 20
    
    var ratioShown: Double {
        if ratio == 0 {
            return 0
        }
        return (1 - ((1 - ratio).truncatingRemainder(dividingBy: 0.5)) * 2)
    }
    
    var body: some View {
        return DamageBar(ratio: ratioShown, slowAmount: slowAmount, height: height)
    }
    
}

struct DamageBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            DamageBar(ratio: 6/6, slowAmount: 0/6)
            DamageBar(ratio: 5/6, slowAmount: 1/6)
            DamageBar(ratio: 4/6, slowAmount: 2/6)
            DamageBar(ratio: 3/6, slowAmount: 3/6)
            DamageBar(ratio: 2/6, slowAmount: 4/6)
            DamageBar(ratio: 1/6, slowAmount: 5/6)
            DamageBar(ratio: 0/6, slowAmount: 6/6)
        }
        VStack(spacing: 20) {
            StagedDamageBar(ratio: 6/6, slowAmount: 0/6)
            StagedDamageBar(ratio: 5/6, slowAmount: 1/6)
            StagedDamageBar(ratio: 4/6, slowAmount: 2/6)
            StagedDamageBar(ratio: 3/6, slowAmount: 3/6)
            StagedDamageBar(ratio: 2/6, slowAmount: 4/6)
            StagedDamageBar(ratio: 1/6, slowAmount: 5/6)
            StagedDamageBar(ratio: 0/6, slowAmount: 6/6)
        }
    }
}
