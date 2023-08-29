//
//  Gradient Extensions.swift
//
//
//  Created by Sean Lee on 8/29/23.
//

import Foundation
import SwiftUI

public extension LinearGradient {
    static var bgRev = LinearGradient(gradient: Gradient(colors: [.background, .darkBlueBg]), startPoint: .top, endPoint: .bottom)
    static var bg = LinearGradient(gradient: Gradient(colors: [.background, .darkBlueBg]), startPoint: .bottom, endPoint: .top)

}
