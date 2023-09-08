//
//  DamageBar.swift
//  slowdown
//
//  Created by Sean Lee on 1/7/23.
//

import Controllers
import Foundation
import RangeMapping
import SwiftUI

struct DamageBar: View {
    // current hp / hp max
    var ratio: Double

    var magnitude: Double {
        abs(ratio)
    }

    var alignment: Alignment {
        if ratio < 0 {
            return .trailing
        }
        return .leading
    }

    var offsetMultiplier: Double {
        if ratio < 0 {
            return -1
        }
        return 1
    }

    var slowAmount: Double = 0

    var height: Double = 20

    var color: Color {
        if 1 - slowAmount < 0.5 {
            return .yellow
        }
        return .green
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: alignment) {
                Rectangle()
                    .fill(color)
                    .frame(width: geometry.size.width, height: height)
                    .mask(alignment: alignment) {
                        RoundedRectangle(cornerRadius: 100)
                            .opacity(1)
                            .frame(width: geometry.size.width, height: height)
                    }
                    .mask(alignment: alignment) {
                        RoundedRectangle(cornerRadius: 100)
                            .fill(color)
                            .offset(x: magnitude * geometry.size.width < height
                                ? (magnitude * geometry.size.width - height) * offsetMultiplier
                                : 0)
                            .frame(width: max(height, geometry.size.width * magnitude), height: height)
                    }
                RoundedRectangle(cornerRadius: 100)
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
    var slowAmount: Double {
        ratio.applyMapping(Mapping(a: 0, b: 1, c: 1, d: 0))
    }

    var height: Double = 20

    var ratioShown: Double {
        ratio.applyMapping(Mapping(a: 0, b: 1, c: -1, d: 1))
    }

    var body: some View {
        DamageBar(ratio: ratioShown, slowAmount: slowAmount, height: height)
    }
}

struct WiredStagedDamageBar: View {
    @EnvironmentObject var stateController: StateController
    @EnvironmentObject var settingsStore: SettingsStore
    var height: Double
    var body: some View {
        let ratio = 1 - stateController.state.usagePoints / settingsStore.activePreset.usageMaxHp

        return StagedDamageBar(ratio: ratio, height: height)
    }
}

struct DamageBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            DamageBar(ratio: 6 / 6, slowAmount: 0 / 6)
            DamageBar(ratio: 5 / 6, slowAmount: 1 / 6)
            DamageBar(ratio: 4 / 6, slowAmount: 2 / 6)
            DamageBar(ratio: 3 / 6, slowAmount: 3 / 6)
            DamageBar(ratio: 2 / 6, slowAmount: 4 / 6)
            DamageBar(ratio: 1 / 6, slowAmount: 5 / 6)
            DamageBar(ratio: 0.06, slowAmount: 6 / 6)
        }
    }
}

struct StagedDamageBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            StagedDamageBar(ratio: 6 / 6)
            StagedDamageBar(ratio: 5 / 6)
            StagedDamageBar(ratio: 4 / 6)
            StagedDamageBar(ratio: 0.51)
            StagedDamageBar(ratio: 3 / 6)
            StagedDamageBar(ratio: 0.49)
            StagedDamageBar(ratio: 2 / 8)
            StagedDamageBar(ratio: 1 / 6)
            StagedDamageBar(ratio: 0 / 6)
        }
    }
}
