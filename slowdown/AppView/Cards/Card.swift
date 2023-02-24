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
    var backgroundColor: Color? = Color.white.opacity(0)
    
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
        .foregroundColor(Color.white)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
            .stroke(.ultraThinMaterial)
            .foregroundColor(backgroundColor)
        )
    }
}
