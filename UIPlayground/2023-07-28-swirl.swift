//
//  2023-07-28-swirl.swift
//  UIPlayground
//
//  Created by Sean Lee on 7/28/23.
//

import Inject
import SwiftUI

struct SpiralTwoPhase: Shape {
    let innerRadius: Double
    let numRotations: Double = 2

    var t: Double
    var td: Double {
        easeInOutCubic(t)
    }

    var d: Double {
        return innerRadius / (numRotations + 2) * sin(td * .pi / 2)
    }

    var start: Double {
        .pi / 2.0
    }

    var end: Double {
        return .pi / 2 + 2 * .pi + td * numRotations * 2 * .pi
    }

    var animatableData: Double {
        get { t }
        set {
            t = newValue
        }
    }

    func easeInOutCubic(_ x: Double) -> Double {
        return x < 0.5 ? 4 * x * x * x : 1 - pow(-2 * x + 2, 3) / 2;
    }

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()

        let k = 0.01 
        let s: Double = end - start > 0 ? k : -k

        for t in stride(from: start, to: end, by: s) {
            let radius = innerRadius - d * t / (2.0 * .pi)

            let x = center.x + CGFloat(radius * cos(t))
            let y = center.y + CGFloat(radius * sin(t))

            if t == start {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        return path
    }
}

struct SpiralView: View {
    @ObserveInjection var inject
    @State var t: Double = 0.0

    var body: some View {
        VStack {
            SpiralTwoPhase(innerRadius: UIScreen.main.bounds.width / 2 * 0.9, t: t)
            .stroke(Color.black, lineWidth: 1)
            .background(Color.white)
            .frame(width: 400, height: 400)
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 3).repeatForever(autoreverses: true)
                ) {
                    if self.t == 0.0 {
                        self.t = 1.0
                    } else {
                        self.t = 0.0
                    }
                }
            }
        }
        .enableInjection()
    }
}


struct x_2023_07_28_swirl: View {
    var body: some View {
        SpiralView()
    }
}