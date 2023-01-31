//
//  Extensions.swift
//  slowdown
//
//  Created by Sean Lee on 1/22/23.
//

import Foundation
import SwiftUI

extension Color {
    public func lighter(by amount: CGFloat = 0.2) -> Self { Self(UIColor(self).lighter(by: amount)) }
    public func darker(by amount: CGFloat = 0.2) -> Self { Self(UIColor(self).darker(by: amount)) }
}

extension UIColor {
    func mix(with color: UIColor, amount: CGFloat) -> Self {
        var red1: CGFloat = 0
        var green1: CGFloat = 0
        var blue1: CGFloat = 0
        var alpha1: CGFloat = 0

        var red2: CGFloat = 0
        var green2: CGFloat = 0
        var blue2: CGFloat = 0
        var alpha2: CGFloat = 0

        getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        color.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)

        return Self(
            red: red1 * CGFloat(1.0 - amount) + red2 * amount,
            green: green1 * CGFloat(1.0 - amount) + green2 * amount,
            blue: blue1 * CGFloat(1.0 - amount) + blue2 * amount,
            alpha: alpha1
        )
    }

    func lighter(by amount: CGFloat = 0.2) -> Self { mix(with: .white, amount: amount) }
    func darker(by amount: CGFloat = 0.2) -> Self { mix(with: .black, amount: amount) }
}

enum Warp {
    case linear
    case exponential
}

struct Mapping {
    let a: Double
    let b: Double
    let c: Double
    let d: Double
    var inWarp: Warp = .linear
    var outWarp: Warp = .linear
    var clip: Bool = false
    
    func map(_ x: Double) -> Double {
        var y = x
        // 1) normalize
        switch inWarp {
        case .linear:
            y = (y - a) / (b - a)
        case .exponential:
            y = (log(y) - log(a)) / (log(b) - log(a))
        }
        
        // 2) scale
        switch outWarp {
        case .linear:
            y = d * y + c * (1 - y)
        case .exponential:
            y = pow(d, y) * pow(c, 1 - y)
        }
        if clip {
            let lowerBound = min(c, d)
            let upperBound = max(c, d)
            y = max(min(y, upperBound), lowerBound)
        }
        return y
    }
    
    var inverse: Mapping {
        if clip {
            fatalError("cannot invert clipped mapping")
        }
        return Mapping(a: c, b: d, c: a, d: b, inWarp: outWarp, outWarp: inWarp)
    }
}

extension Double {
    func applyMapping(_ mapping: Mapping) -> Double {
        return mapping.map(self)
    }
}

extension FloatingPoint {
  @inlinable
  func signum( ) -> Self {
    if self < 0 { return -1 }
    if self > 0 { return 1 }
    return 0
  }
}

extension View {
    public func removeFocusOnTap(enabled: Bool) -> some View {
        self.onTapBackground(enabled: enabled) {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        }
    }
}

extension View {
    @ViewBuilder
    private func onTapBackgroundContent(enabled: Bool, _ action: @escaping () -> Void) -> some View {
        if enabled {
            Color.clear
                .frame(width: UIScreen.main.bounds.width * 2, height: UIScreen.main.bounds.height * 2)
                .contentShape(Rectangle())
                .onTapGesture(perform: action)
        }
    }

    func onTapBackground(enabled: Bool, _ action: @escaping () -> Void) -> some View {
        background(
            onTapBackgroundContent(enabled: enabled, action)
        )
    }
}

