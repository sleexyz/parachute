//
//  PrimaryButton.swift
//  slowdown
//
//  Created by Sean Lee on 4/28/22.
//

import SwiftUI
import Foundation
import UIKit


struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    @Binding var isLoading: Bool

    var body: some View {
        Button(action: self.action) {
            ZStack {
                Spinner(isAnimating: $isLoading, color: .white, style: .medium)
                Text(title)
                    .opacity(isLoading ? 0 : 1)
            }
        }
            .disabled(isLoading)
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundColor(Color.white)
            .background(Color.blue)
            .cornerRadius(8)
    }
}

struct PrimaryButtonView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PrimaryButton(title: "Action", action: {}, isLoading: .constant(false))
                .previewLayout(.fixed(width: 300, height: 80))

            PrimaryButton(title: "Action", action: {}, isLoading: .constant(false))
                .previewLayout(.fixed(width: 300, height: 80))
                .environment(\.colorScheme, .dark)

            PrimaryButton(title: "Action", action: {}, isLoading: .constant(true))
                .previewLayout(.fixed(width: 300, height: 80))
        }
    }
}
