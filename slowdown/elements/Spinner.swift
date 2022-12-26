//
//  Spinner.swift
//  slowdown
//
//  Created by Sean Lee on 4/28/22.
//

import SwiftUI

struct Spinner: UIViewRepresentable {
    var isAnimating: Bool

    let color: UIColor
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: style)
        indicator.hidesWhenStopped = true
        indicator.color = color
        return indicator
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct Spinner_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Spinner(isAnimating: true, color: .black, style: .medium)
            Spinner(isAnimating: false, color: .black, style: .medium)
        }
    }
}
