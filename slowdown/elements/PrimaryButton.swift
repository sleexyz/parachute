//
//  PrimaryButton.swift
//  slowdown
//
//  Created by Sean Lee on 4/28/22.
//

import SwiftUI
import Foundation
import UIKit


struct PrimaryButton<LoadingView: View>: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool
    var loadingMessage: LoadingView
    
    init(title: String, action: @escaping () -> Void, isLoading: Bool, loadingMessage: LoadingView = EmptyView()) {
        self.title = title
        self.action = action
        self.isLoading = isLoading
        self.loadingMessage = loadingMessage
    }

    var body: some View {
        Button(action: self.action) {
            ZStack {
                if type(of: loadingMessage) != EmptyView.self {
                    loadingMessage.opacity(isLoading ? 1 : 0)
                } else {
                    Spinner(isAnimating: isLoading, color: .black, style: .medium)
                }
                Text(title)
                    .opacity(isLoading ? 0 : 1)
                    .frame(maxWidth: .infinity)
            }
        }
            .disabled(isLoading)
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundColor(Color.black)
            .background(Color.black.opacity(0.1))
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
