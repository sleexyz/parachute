//
//  SplashView.swift
//  slowdown
//
//  Created by Sean Lee on 4/28/22.
//

import SwiftUI

struct SplashView: View {
    var text: String?
    var body: some View {
        Text(text ?? "welcome")
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
