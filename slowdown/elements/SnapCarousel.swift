//
//  SnapCarousel.swift
//  slowdown
//
//  Created by Sean Lee on 1/5/23.
//

import Foundation
import SwiftUI
import Logging

struct SnapCarousel<Content: View>: View {
    let logger = Logger.init(label: "industries.strange.slowdown.SnapCarousel")
    var content: (Mode) -> Content
    var list: [Mode]
    
    // Properties....
    var spacing: CGFloat
    var trailingSpace: CGFloat
    @Binding var index: Int
    
    init(spacing: CGFloat = 0, trailingSpace: CGFloat = 0, index: Binding<Int>, items: [Mode], @ViewBuilder content: @escaping (Mode)->Content){
        self.list = items
        self.spacing = spacing
        self.trailingSpace = trailingSpace
        self._index = index
        self.content = content
    }
    
    // Offset...
    @GestureState var gestureOffset: CGFloat = 0
    @State var programmaticOffset: CGFloat = 0
    @State var currentIndex: Int = 0
    
    @State var animationCompleteTimer: Timer?
    
    var body: some View {
        GeometryReader{proxy in
            let width = proxy.size.width - ( trailingSpace - spacing )
            HStack (spacing: spacing) {
                ForEach(list) { item in
                    content(item)
                        .frame(minWidth: UIScreen.main.bounds.size.width, maxHeight: .infinity)

                }

            }
            // To make the edges draggable
            .contentShape(Rectangle())
            .padding(.horizontal, spacing)
            .offset(x: (CGFloat(currentIndex) * -width) + gestureOffset + programmaticOffset)
            .onChange(of: self.index) { _ in
                if currentIndex != index {
                    programmaticOffset = CGFloat(index - currentIndex) * -width
                    self.animationCompleteTimer?.invalidate()
                    self.animationCompleteTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) {_ in
                        currentIndex = index
                        programmaticOffset = 0
                        
                    }
                }
            }
            .highPriorityGesture(
                DragGesture(minimumDistance: 8, coordinateSpace: .local)
                    .updating($gestureOffset, body: { value, out, _ in
                        out = value.translation.width
                    })
                    .onEnded({ value in
                        let offsetX = value.translation.width
                        if abs(offsetX) < 50 {
                            return
                        }
                        let lastIndex = currentIndex
                        if offsetX > 0 {
                            currentIndex = max(min(currentIndex - 1, list.count - 1), 0)
                        }
                        if offsetX < 0 {
                            currentIndex = max(min(currentIndex + 1, list.count - 1), 0)
                        }
                        if index != currentIndex {
                            list[lastIndex].onExit?()
                            list[currentIndex].onEnter?()
                        }
                        index = currentIndex
                    })
            )
            
        }
        .animation(.interpolatingSpring(mass: 0.1, stiffness: 20, damping: 2), value: programmaticOffset)
        .animation(.interpolatingSpring(mass: 0.1, stiffness: 20, damping: 2), value: gestureOffset)
//        .animation(.easeInOut(duration: 0.5), value: offset)
        
    }

}

struct Mode: Identifiable {
    var id: String
    var onEnter: (() -> Void)?
    var onExit: (() -> Void)?
}
