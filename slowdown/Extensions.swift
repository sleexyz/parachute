//
//  Extensions.swift
//  slowdown
//
//  Created by Sean Lee on 1/22/23.
//

import Foundation
import SwiftUI

extension Double {
    // TODO: add curve
    func linlin(_ a: Double,_ b: Double,_ c: Double,_ d: Double) -> Double {
        return (self - a) * (d - c)/(b - a) + c
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

