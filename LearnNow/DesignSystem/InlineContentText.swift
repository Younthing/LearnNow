import Foundation
import LearnNowContentKit
import SwiftUI

struct InlineContentText: View {
    let content: [InlineContent]

    var body: some View {
        Text(content.renderedAttributedString())
    }
}

extension Array where Element == InlineContent {
    var plainText: String {
        map(\.plainText).joined()
    }

    fileprivate func renderedAttributedString(
        intents: InlinePresentationIntent = []
    ) -> AttributedString {
        reduce(into: AttributedString()) { result, item in
            result.append(item.renderedAttributedString(intents: intents))
        }
    }
}

private extension InlineContent {
    func renderedAttributedString(
        intents: InlinePresentationIntent
    ) -> AttributedString {
        switch self {
        case let .text(value):
            attributedString(value, intents: intents)
        case let .emphasis(children):
            children.renderedAttributedString(intents: intents.union(.emphasized))
        case let .strong(children):
            children.renderedAttributedString(intents: intents.union(.stronglyEmphasized))
        case let .code(value):
            attributedString(value, intents: intents.union(.code))
        case .lineBreak:
            attributedString("\n", intents: intents)
        }
    }

    func attributedString(
        _ value: String,
        intents: InlinePresentationIntent
    ) -> AttributedString {
        var result = AttributedString(value)
        if !intents.isEmpty {
            result.inlinePresentationIntent = intents
        }
        return result
    }
}
