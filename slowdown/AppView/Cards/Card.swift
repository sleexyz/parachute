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
    var caption: String?
    var backgroundColor: Color?
    var material: S
    
    @ViewBuilder
    var content: () -> Content
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(.headline.bold())
                    .padding(.top, CARD_PADDING)
                    .padding(.leading, CARD_PADDING)
                Spacer()
            }
            Spacer()
                .frame(minHeight: 0)
            content()
                .padding(40)
            Spacer()
                .frame(minHeight: 0)
            if caption != nil {
                HStack {
                    Text(caption!)
                        .font(.caption)
                        .padding(.bottom, CARD_PADDING)
                        .padding(.leading, CARD_PADDING)
                    Spacer()
                }
            }
        }
        .background(backgroundColor ?? .clear)
        .background(material)
        .clipShape(RoundedRectangle(cornerRadius: CARD_PADDING, style: .continuous))
//        .shadow(color: .black.lighter(), radius: 1, x: 0, y: 1)
        .overlay(RoundedRectangle(cornerRadius: CARD_PADDING, style: .continuous)
            .stroke(.ultraThinMaterial)
//            .foregroundColor(backgroundColor)
        )
    }
}
