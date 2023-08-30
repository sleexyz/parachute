
import SwiftUI

public extension ButtonStyle where Self == DottedButtonStyle {
    static var dotted: some ButtonStyle {
        DottedButtonStyle()
    }
}

// public struct BorderedButtonStyle: ButtonStyle {
//     public func makeBody(configuration: Configuration) -> some View {
//         configuration.label
//             .foregroundColor(.parachuteOrange) 
//             .padding(10)
//             .background(
//                 Capsule()
//                     .stroke(style: StrokeStyle(lineWidth: 1))
//                     .background(Capsule().fill(Color.parachuteOrange.opacity(0.25)))
//                     .foregroundColor(.parachuteOrange.opacity(0.5)) 
//             )
//     }
// } 


public struct DottedButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("SpaceMono-Regular", size: 16))
    }
}

extension View {

    public func glow(color: Color, radius: CGFloat = 54) -> some View {
        self
        .shadow(color: color, radius: radius / 3)
        .shadow(color: color, radius: radius / 3)
        .shadow(color: color, radius: radius / 3)
    }

    public func rrGlow(color: Color, bg: Color = .clear, radius: CGFloat = 54) -> some View {
        self.background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(style: StrokeStyle(lineWidth: 1))
                // .overlay(self.blur(radius: radius / 6))
                .foregroundColor(color.opacity(0.1))
                .glow(color: color, radius:radius)
                // .shadow(color: color, radius: radius / 3)
                // .shadow(color: color, radius: radius / 3)
                // .shadow(color: color, radius: radius / 3)
                .reverseMask {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                }
                .background {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(bg)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .edgesIgnoringSafeArea(.all)
        )
    }


    @inlinable
    public func reverseMask<Mask: View>(
        alignment: Alignment = .center,
        @ViewBuilder _ mask: () -> Mask
    ) -> some View {
        self.mask {
            Capsule()
                .stroke(style: StrokeStyle(lineWidth: 200))
                .foregroundColor(.white)
                .overlay(alignment: alignment) {
                mask()
                    .blendMode(.destinationOut)
                }
        }
    }
}
