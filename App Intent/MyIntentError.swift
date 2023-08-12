//
//  MyIntentError.swift
//  slowdown
//
//  Created by Sean Lee on 8/11/23.
//

import Foundation

enum MyIntentError: Swift.Error, CustomLocalizedStringResourceConvertible {
    case general
    case message(_ message: String)

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case let .message(message): return "Error: \(message)"
        case .general: return "My general error"
        }
    }
}
