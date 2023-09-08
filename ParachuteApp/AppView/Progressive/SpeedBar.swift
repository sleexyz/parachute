//
//  SpeedBar.swift
//  slowdown
//
//  Created by Sean Lee on 1/30/23.
//

import Foundation
import RangeMapping
import SwiftUI

struct SpeedBar: View {
    @Binding var speed: Double
    var minSpeed: Double
    var maxSpeed: Double
    var publish: () -> Void

    private var speedToSlider: Mapping {
        Mapping(a: 40e3, b: 10e6, c: 0, d: 100, inWarp: .exponential)
    }

    private var sliderToSpeed: Mapping {
        speedToSlider.inverse
    }

    private var sliderVal: Binding<Double> {
        Binding {
            speed.applyMapping(speedToSlider)
        } set: {
            speed = $0.applyMapping(sliderToSpeed)
        }
    }

    private static func formatText(speed: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.usesSignificantDigits = true
        numberFormatter.roundingMode = .down
        numberFormatter.maximumSignificantDigits = 1
        if speed >= 1e9 {
            return String(format: "%s gbps", numberFormatter.string(from: NSNumber(value: speed / 1e9))!)
        }
        if speed >= 1e6 {
            return "\(numberFormatter.string(from: NSNumber(value: speed / 1e6))!) mbps"
        }
        if speed >= 1e3 {
            return "\(numberFormatter.string(from: NSNumber(value: speed / 1e3))!) kbps"
        }
        return "\(numberFormatter.string(from: NSNumber(value: speed))!) bps"
    }

    var body: some View {
        VStack {
            Slider(
                value: sliderVal,
                in: 0 ... 100,
                onEditingChanged: { editing in
                    if !editing {
                        publish()
                        //                        controller.syncSettings()
                    }
                }
            ).padding()
            Text(SpeedBar.formatText(speed: speed))
        }
    }
}

struct SpeedBarPreviewContainer<Content: View>: View {
    @State var speed: Double = 50e3
    var render: (Binding<Double>) -> Content
    var body: some View {
        render($speed)
    }
}

struct SpeedBar_Previews: PreviewProvider {
    static var previews: some View {
        SpeedBarPreviewContainer { $speed in
            SpeedBar(speed: $speed, minSpeed: 50e3, maxSpeed: 10e6, publish: {})
        }
    }
}
