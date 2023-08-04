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
    var isLoading: Bool
    
    init(title: String, action: @escaping () -> Void, isLoading: Bool) {
        self.title = title
        self.action = action
        self.isLoading = isLoading
    }

    var body: some View {
        Button(action: self.action) {
            ZStack {
                Spinner(isAnimating: isLoading, color: .black, style: .medium)
                Text(title)
                    .opacity(isLoading ? 0 : 1)
                    .frame(maxWidth: .infinity)
            }
        }
            .disabled(isLoading)
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundColor(Color.white)
            .background(Color.accentColor.grayscale(1))
            .cornerRadius(8)
    }
}

struct PrimaryButtonView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PrimaryButton(title: "Action", action: {}, isLoading: false)
                .previewLayout(.fixed(width: 300, height: 80))

            PrimaryButton(title: "Action", action: {}, isLoading: false)
                .previewLayout(.fixed(width: 300, height: 80))
                .environment(\.colorScheme, .dark)

            PrimaryButton(title: "Action", action: {}, isLoading: true)
                .previewLayout(.fixed(width: 300, height: 80))
        }
    }
}
