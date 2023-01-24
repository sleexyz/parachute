//
//  Extensions.swift
//  slowdown
//
//  Created by Sean Lee on 1/22/23.
//

import Foundation
import SwiftUI

struct Consumer<T: ObservableObject>: ViewModifier {
    let type: T.Type
    @EnvironmentObject private var obj: T
    let effect: (_ value: T) -> ()
    func body(content: Content) -> some View {
        return content.onAppear {
            effect(obj)
        }
    }
}

enum Warp {
    case linear
    case exponential
}

extension Double {
    func linmap(_ a: Double,_ b: Double,_ c: Double,_ d: Double, warp: Warp = .linear, clip: Bool = false) -> Double {
        // normalized
        var y = (self - a) / (b - a)
        // scaled
        switch warp {
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

