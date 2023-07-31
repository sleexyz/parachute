import SwiftUI

struct CarouselItem<Content: View>: Identifiable {
    let id = UUID()
    let content: Content
}

struct CarouselView: View {
    @State private var currentPage: Int = 0

    let content: () -> [AnyView]

    init(content: @escaping () -> [AnyView]) {
        self.content = content
    }

    var body: some View {
        let carouselItems = content().map { CarouselItem(content: $0) }

        GeometryReader { geometry in
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(carouselItems) { item in
                            item.content
                                .frame(width: geometry.size.width, height: geometry.size.height)
                        }
                    }
                    .frame(width: geometry.size.width, alignment: .leading)
                    .offset(x: CGFloat(currentPage) * -geometry.size.width, y: 0)
                    .animation(.spring(), value: currentPage)
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                let offset = value.translation.width
                                let currentPage = CGFloat(self.currentPage)
                                if offset < 0 {
                                    if currentPage < CGFloat(carouselItems.count - 1) {
                                        self.currentPage = Int(currentPage + 1)
                                    }
                                } else {
                                    if currentPage > 0 {
                                        self.currentPage = Int(currentPage - 1)
                                    }
                                }
                            })
                    )
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                // .clipped()

                PageControl(numberOfPages: carouselItems.count, currentPage: $currentPage)
            }
        }
    }
}

struct PageControl: View {
    let numberOfPages: Int
    @Binding var currentPage: Int

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<numberOfPages) { page in
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(page == currentPage ? .blue : .gray)
            }
        }
        .padding(10)
    }
}