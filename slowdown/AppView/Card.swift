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
    var backgroundColor: Color?
    
    @ViewBuilder
    var content: () -> Content
    
    var body: some View {
        VStack {
            VStack {
                HStack{
                    Text(title)
                        .font(.title.bold())
                    Spacer()
                }
                .padding(.bottom, 120)
                if caption != nil {
                    HStack{
                        Text(caption!)
                            .font(.caption)
                        Spacer()
                    }
                }
                content()
            }
            .padding(20)
        }
        .foregroundColor(Color.white)
        .background(backgroundColor ?? Color.white.opacity(0))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding()
    }
}
