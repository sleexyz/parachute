//
//  Animation Globals.swift
//  slowdown
//
//  Created by Sean Lee on 8/4/23.
//

import SwiftUI

var ANIMATION_SECS: Double = 0.35
var ANIMATION: Animation = .timingCurve(0.30, 0.20, 0, 1, duration: ANIMATION_SECS * 1.7)
var ANIMATION_SHORT: Animation = .timingCurve(0.30, 0.20, 0, 1, duration: ANIMATION_SECS)
