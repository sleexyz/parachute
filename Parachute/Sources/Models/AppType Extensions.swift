import ProxyService

public extension Proxyservice_AppType {
    var familyActivitySelectionKey: String {
        "familyActivitySelectionKey-\(self.rawValue)"
    }

    // User facing name:
    var name: String {
        switch self {
        case .instagram:
            return "Instagram"
        case .tiktok:
            return "TikTok"
        case .twitter:
            return "Twitter / X"
        case .youtube:
            return "YouTube"
        case .facebook:
            return "Facebook"
        case let .UNRECOGNIZED(int):
            return "Unknown (\(int))"
        }
    }
}
