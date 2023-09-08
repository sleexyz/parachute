//
//  Card.swift
//  slowdown
//
//  Created by Sean Lee on 2/20/23.
//

import Controllers
import Foundation
import SwiftUI

private struct CardExpandedKey: EnvironmentKey {
    static let defaultValue = false
}

private struct CaptionShownKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var cardExpanded: Bool {
        get { self[CardExpandedKey.self] }
        set { self[CardExpandedKey.self] = newValue }
    }

    var captionShown: Bool {
        get { self[CaptionShownKey.self] }
        set { self[CaptionShownKey.self] = newValue }
    }

//    var closedStackPosition: StackPosition {
//        get { self[ClosedStackPositionKey.self] }
//        set { self[ClosedStackPositionKey.self] = newValue }
//    }
}

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
    @Environment(\.cardExpanded) var cardExpanded: Bool
    @Environment(\.captionShown) var captionShown: Bool

    @EnvironmentObject var profileManager: ProfileManager

    @State var animationInitialized: Bool = false

    var maxHeight: Double {
        if cardExpanded {
            return .infinity
        }
        return minHeight
    }

    var maxHeightContent: Double {
        if cardExpanded {
            return .infinity
        }
        return 0
    }

    var minHeight: Double {
        if !captionShown {
            return 120
        }
        return 120
    }

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
                        .background(computedBackgroundColor.bakeAlpha(colorScheme).deepen(1).opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: CARD_PADDING, style: .continuous))
                        .padding(CARD_PADDING - 10)
                        .zIndex(2)
//                        .transition(AnyTransition.asymmetric(
//                            insertion: .opacity.animation(ANIMATION.delay(ANIMATION_SECS * 2)),
//                            removal: .identity
//                        ))
                }
            }
            .frame(height: minHeight / 2, alignment: .top)
            .foregroundColor(computedBackgroundColor.bakeAlpha(colorScheme).getForegroundColor())
            .background(computedBackgroundColor)
            .animation(ANIMATION, value: cardExpanded)

            content()
                .frame(maxWidth: .infinity, maxHeight: maxHeightContent)
                .opacity(cardExpanded ? 1 : 0)
//                .animation(ANIMATION.delay(ANIMATION_SECS/2), value: cardExpanded)
//                .transition(AnyTransition.asymmetric(
//                    insertion: .opacity.animation(ANIMATION.delay(ANIMATION_SECS)),
//                    removal: .opacity.animation(ANIMATION)
//                ))
//                .matchedGeometryEffect(id: "content_" + id, in: namespace)

            ZStack {
                Rectangle().frame(minHeight: 0).opacity(0)
//                if caption != nil && computedCaptionShown {
                if caption != nil {
                    Text(caption!)
                        .font(.caption)
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            alignment: .bottomLeading
                        )
                        .padding(CARD_PADDING)
                        .transition(AnyTransition.asymmetric(
                            insertion: .opacity.animation(ANIMATION.delay(ANIMATION_SECS * 2)),
                            removal: .identity
                        ))
                }
            }
            .frame(height: minHeight / 2, alignment: .bottom)
            .foregroundColor(computedBackgroundColor.bakeAlpha(colorScheme).getForegroundColor())
            .background(computedBackgroundColor)
            .animation(ANIMATION, value: cardExpanded)
        }
        .background(material)
        .clipShape(RoundedRectangle(cornerRadius: CARD_PADDING, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: CARD_PADDING, style: .continuous)
            .stroke(.ultraThinMaterial)
        )
//        .animation(ANIMATION.delay(ANIMATION_SECS/2), value: cardExpanded)
        .onAppear {
            animationInitialized = true
        }
        .animation(ANIMATION_SHORT, value: caption) // Semi-hack to animate transitions within a card
        .matchedGeometryEffect(id: id, in: namespace)
    }
}
