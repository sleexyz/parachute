//
//  Card.swift
//  slowdown
//
//  Created by Sean Lee on 2/20/23.
//

import Foundation
import SwiftUI

internal struct CardHeightKey: EnvironmentKey {
    static let defaultValue = Double(0)
}

internal struct CardYOffsetKey: EnvironmentKey {
    static let defaultValue = Double(0)
}

extension EnvironmentValues {
    var cardHeight: Double {
        get { self[CardHeightKey.self] }
        set { self[CardHeightKey.self] = newValue }
    }
    var cardYOffset: Double {
        get { self[CardYOffsetKey.self] }
        set { self[CardYOffsetKey.self] = newValue }
    }
}

struct Card<Content: View>: View {
    var title: String
    var caption: String?
    var backgroundColor: Color? = Color.white.opacity(0)
    
    @ViewBuilder
    var content: () -> Content
    
    @Environment(\.cardHeight) var height: Double
    @Environment(\.cardYOffset) var y: Double
    
    var body: some View {
        VStack {
//            GeometryReader { proxy in
            HStack {
                Text(title)
                    .font(.title.bold())
                    .padding(20)
                Spacer()
            }
            Spacer()
//                    .ali
//                    .position(
//                        x:proxy.frame(in:.global).minX,
//                        y:proxy.frame(in:.global).minY
//                    )
//            }
            if caption != nil {
                HStack {
                    Text(caption!)
                        .font(.caption)
                        .padding(20)
                    Spacer()
                }
            }
//            Rectangle()
//                .opacity(0).frame(width: .infinity, height: height)
        }
        .foregroundColor(Color.white)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
            .stroke(.ultraThinMaterial)
            .foregroundColor(backgroundColor)
        )
        .offset(x: 0, y: y)
        .frame(height: height)
        .animation(
            .spring(response:  0.50, dampingFraction: 0.825, blendDuration: 0),
            value: "\(y) \(height)"
        )
    }
}
