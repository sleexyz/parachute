//
//  Card.swift
//  slowdown
//
//  Created by Sean Lee on 2/20/23.
//

import Foundation
import SwiftUI

struct Card<Content: View>: View {
    var title: String
    var caption: String?
    var backgroundColor: Color? = .clear
    
    @ViewBuilder
    var content: () -> Content
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(.title.bold())
                    .padding(20)
                Spacer()
            }
            Spacer()
                .frame(minHeight: 0)
            content()
                .padding(20)
            Spacer()
                .frame(minHeight: 0)
            if caption != nil {
                HStack {
                    Text(caption!)
                        .font(.caption)
                        .padding(20)
                    Spacer()
                }
            }
        }
        .background(backgroundColor)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
//        .shadow(color: .black.lighter(), radius: 2, x: 0, y: 1)
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
            .stroke(.ultraThinMaterial)
            .foregroundColor(backgroundColor)
        )
    }
}
