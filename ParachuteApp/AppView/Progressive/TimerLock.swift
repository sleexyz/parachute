//
//  TimerLock.swift
//  slowdown
//
//  Created by Sean Lee on 2/20/23.
//

import Foundation
import SwiftUI
import Combine

struct TimerLock<Content: View>: View{
    var content: (_ timeLeft: Int) -> Content
    @Environment(\.scenePhase) var scenePhase

    @State var timeLeft: Int = 10
    @State var timer: AnyCancellable?
    

    var body: some View {
        content(timeLeft)
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    startSubscription()
                } else {
                    timer?.cancel()
                }
            }
            .onAppear {
                startSubscription()
            }
    }
    
    func startSubscription() {
        timeLeft = 10
        timer?.cancel()
        timer = Timer.publish(every: 1, tolerance: 0, on: .main, in: .common).autoconnect()
            .sink { _ in
                if timeLeft == 0 {
                    timer?.cancel()
                    return
                }
                timeLeft -= 1
            }
    }
}

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
