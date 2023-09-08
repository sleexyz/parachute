import Foundation

enum RpcError: Error {
    case serverNotInitializedError
    case nilResponseError
    case downstreamError(String)
}

extension RpcError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .nilResponseError: return NSLocalizedString("Server returned nil response", comment: "")
        case .serverNotInitializedError: return NSLocalizedString("Server not initialized", comment: "")
        case let .downstreamError(message): return NSLocalizedString("Downstream error: \(message)", comment: "")
        }
    }
}
