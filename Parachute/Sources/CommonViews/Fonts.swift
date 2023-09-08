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
