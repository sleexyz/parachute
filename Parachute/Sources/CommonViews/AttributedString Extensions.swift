import SwiftUI

extension AttributedString {
    
    public init(markdown: String, boldFont: Font) {
        try! self.init(
            markdown: markdown,
            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )
        self.customBoldStyle(boldFont: boldFont)
    }

    public mutating func customBoldStyle(boldFont: Font) {
        var sourceContainer = AttributeContainer()
        sourceContainer.inlinePresentationIntent = .stronglyEmphasized

        var targetContainer = AttributeContainer()

        targetContainer.font = boldFont

        self.replaceAttributes(sourceContainer, with: targetContainer) // return self.transformingAttributes(InlinePresentationIntent.stronglyEmphasized) { t in
    }

}
