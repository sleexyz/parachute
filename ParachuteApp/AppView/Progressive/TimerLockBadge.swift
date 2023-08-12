//
//  TimerLock.swift
//  slowdown
//
//  Created by Sean Lee on 2/20/23.
//

import Foundation
import SwiftUI
import Combine

struct TimerLockBadge: View {
    var timeLeft: Int
    var body: some View {
        Text("🔒 " + timeLeft.description)
            .frame(width: 60, height: 30)
            .foregroundColor(Color.white)
            .background(Color.accentColor.grayscale(1))
            .clipShape(Capsule())
    }
}
