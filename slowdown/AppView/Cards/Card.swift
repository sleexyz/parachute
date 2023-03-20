//
//  Card.swift
//  slowdown
//
//  Created by Sean Lee on 2/20/23.
//

import Foundation
import SwiftUI

let CARD_PADDING: Double = 20

struct Card<Content: View, S: ShapeStyle>: View {
    var title: String
    var icon: String?
    var badgeText: String?
    var caption: String?
    var backgroundColor: Color?
    var material: S
    var id: String
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.namespace) var namespace: Namespace.ID
    
    @ViewBuilder
    var content: () -> Content
    
    var computedBackgroundColor: Color {
        guard let backgroundColor = backgroundColor else {
            return .clear
        }
        if colorScheme == .dark {
            return backgroundColor.deepenByAlphaAndBake()
        }
        return backgroundColor.bakeAlpha(colorScheme)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                HStack {
                    if icon != nil {
                        Text(icon!)
                            .font(.headline)
                            .padding(.trailing, 4)
                    }
                    Text(title)
                        .font(.headline)
                }
                    .padding(CARD_PADDING)
                Spacer()
                if badgeText != nil {
                    Text(badgeText!)
                        .font(.subheadline.smallCaps())
                        .padding(10)
                        .padding(.leading, 5)
                        .padding(.trailing, 5)
                        .background(computedBackgroundColor.deepen(1).opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: CARD_PADDING, style: .continuous))
                        .padding(CARD_PADDING - 10)
//                        .transition(AnyTransition.asymmetric(
//                            insertion: .opacity.animation(ANIMATION.delay(ANIMATION_SECS * 2)),
//                            removal: .identity
//                        ))
                }
            }
            if caption != nil {
                Text(caption!)
                    .font(.caption)
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .bottomLeading
                    )
                    .padding(.bottom, CARD_PADDING)
                    .padding(.leading, CARD_PADDING)
                    .padding(.trailing, CARD_PADDING)
            }
        }
        .frame(height: 120)
        .foregroundColor(computedBackgroundColor.getForegroundColor())
        .background(computedBackgroundColor)
//        .background(material)
        .clipShape(RoundedRectangle(cornerRadius: CARD_PADDING, style: .continuous))
//        .shadow(color: .black.lighter(), radius: 1, x: 0, y: 1)
        .overlay(RoundedRectangle(cornerRadius: CARD_PADDING, style: .continuous)
            .stroke(.ultraThinMaterial)
//            .foregroundColor(backgroundColor)
        )
        .matchedGeometryEffect(id: id, in: namespace)
    }
}
