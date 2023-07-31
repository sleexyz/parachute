//
//  2023-07-29-swirl.swift
//  UIPlayground
//
//  Created by Sean Lee on 7/29/23.
//

import Inject
import SwiftUI

struct SpiralShape: Shape {
    let innerRadius: Double

    var t: Double

    var tEased: Double {
        let ts = easeInOutCubic((t * 2).truncatingRemainder(dividingBy: 1)) / 2
        return t < 0.5 ? ts : 0.5 + ts
    }

    var d: Double {
        innerRadius / 5 * pow(sin(tEased * 2 * .pi), 2)
    }

    var start: Double {
        .pi / 2.0 - 2 * .pi + min(tEased, 0.5) * 4 * .pi
    }

    var end: Double {
        .pi / 2.0 + 2 * .pi + max(tEased, 0.5) * 4 * .pi
    }

    var animatableData: Double {
        get { t }
        set {
            t = newValue
        }
    }

    func easeInOutCubic(_ x: Double) -> Double {
        return x < 0.5 ? 4 * x * x * x : 1 - pow(-2 * x + 2, 3) / 2
    }

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()

        let s = end - start > 0 ? 0.01 : -0.01

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

struct SpiralShape2: Shape {
    let innerRadius: Double

    var t: Double

    var tEased: Double {
        // t
        let ts = easeInOutCubic((t * 2).truncatingRemainder(dividingBy: 1)) / 2
        let tEased = t < 0.5 ? ts : 0.5 + ts
        return (2 * tEased + 1 * easeInOutCubic(t)) / 3
    }

    var d: Double {
        innerRadius / 4 * pow(sin(tEased * 1 * .pi), 2)
    }

    var start: Double {
        .pi / 2.0
    }

    var end: Double {
        .pi / 2.0 + 2 * .pi + tEased * 4 * .pi
    }

    var animatableData: Double {
        get { t }
        set {
            t = newValue
        }
    }

    func easeInOutCubic(_ x: Double) -> Double {
        return x < 0.5 ? 4 * x * x * x : 1 - pow(-2 * x + 2, 3) / 2
    }

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()

        let s = end - start > 0 ? 0.01 : -0.01

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

struct x_2023_07_29_swirl: View {
    @ObserveInjection var inject
    @State var t: Double = 0.0
    @State var t1: Double = 0.0
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                HStack(alignment: .center) {
                    SpiralShape2(innerRadius: UIScreen.main.bounds.width / 2 * 0.9, t: t1)
                        .stroke(Color.black, lineWidth: 1)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        .onAppear {
                            withAnimation(
                                Animation.linear(duration: 4).repeatForever(autoreverses: false)
                            ) {
                                if self.t1 == 0.0 {
                                    self.t1 = 0.99
                                } else {
                                    self.t1 = 0.0
                                }
                            }
                        }
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.9)
                HStack(alignment: .center) {
                    SpiralShape(innerRadius: UIScreen.main.bounds.width / 2 * 0.9, t: t)
                        .stroke(Color.black, lineWidth: 1)
                        .onAppear {
                            withAnimation(
                                Animation.linear(duration: 8).repeatForever(autoreverses: false)
                            ) {
                                if self.t == 0.0 {
                                    self.t = 1.0
                                } else {
                                    self.t = 0.0
                                }
                            }
                        }
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.9)
            }
        }
        .clipped()
        .enableInjection()
    }
}