import SwiftUI

public extension AttributedString {
    init(markdown: String, boldFont: Font) {
        try! self.init(
            markdown: markdown,
            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )
        customBoldStyle(boldFont: boldFont)
    }

    mutating func customBoldStyle(boldFont: Font) {
        var sourceContainer = AttributeContainer()
        sourceContainer.inlinePresentationIntent = .stronglyEmphasized

        var targetContainer = AttributeContainer()

        targetContainer.font = boldFont

        replaceAttributes(sourceContainer, with: targetContainer) // return self.transformingAttributes(InlinePresentationIntent.stronglyEmphasized) { t in
    }
}
