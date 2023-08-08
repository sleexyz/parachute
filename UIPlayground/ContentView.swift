//
//  ContentView.swift
//  UIPlayground
//
//  Created by Sean Lee on 7/28/23.
//

import Inject
import SwiftUI

struct ContentView: View {
    @ObserveInjection var inject
    var body: some View {
        CarouselView {
            return [
                AnyView(x_2023_07_29_swirl()),
                AnyView(x_2023_07_28_swirl()),
            ]
        }
        .frame(height: UIScreen.main.bounds.height * 0.8) // Set the desired height of the carousel
        .background(Color.white)
        .enableInjection()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
