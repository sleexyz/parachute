import Foundation
import SwiftUI

public enum SpaceMono: String, CaseIterable {
    case regular = "SpaceMono-Regular"
    case italic = "SpaceMono-Italic"
    case bold = "SpaceMono-Bold"
    case boldItalic = "SpaceMono-BoldItalic"
}

public enum Fonts {
    public static func registerFonts() {
        SpaceMono.allCases.forEach {
            registerFont(bundle: .module, fontName: $0.rawValue, fontExtension: "ttf")
        }
    }

    fileprivate static func registerFont(bundle: Bundle, fontName: String, fontExtension: String) {
        bundle.url(forResource: fontName, withExtension: fontExtension)

        guard let fontURL = bundle.url(forResource: fontName, withExtension: fontExtension),
              let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
              let font = CGFont(fontDataProvider)
        else {
            fatalError("Couldn't create font from filename: \(fontName) with extension \(fontExtension)")
        }

        var error: Unmanaged<CFError>?

        CTFontManagerRegisterGraphicsFont(font, &error)
    }
}

public extension Font {
    static func spaceMono(size: CGFloat, weight: Weight = .regular) -> Font {
        switch weight {
        case .regular:
            .custom(SpaceMono.regular.rawValue, size: size)
        case .bold:
            .custom(SpaceMono.bold.rawValue, size: size)
        default:
            .custom(SpaceMono.regular.rawValue, size: size)
        }
    }

    static func mainFont(size: CGFloat, weight: Weight = .regular) -> Font {
        // return .system(size: size, weight: weight, design: .rounded)
        switch weight {
        case .regular:
            .custom(SpaceMono.regular.rawValue, size: size)
        case .bold:
            .custom(SpaceMono.bold.rawValue, size: size)
        default:
            .custom(SpaceMono.regular.rawValue, size: size)
        }
    }
}
