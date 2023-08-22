

public enum AppId {
    case instagram
    case tiktok
    case twitter
    case youtube
}

public struct App {
    public let id: AppId
    public var peekBytes: Int = 128 * 1024
    public var targetRxSpeed: Double = 40_000
}

public extension App {
    static let instagram = App(
        id: .instagram,
        peekBytes: 128 * 1024,
        targetRxSpeed: 40_000
    )
    static let tiktok = App(
        id: .tiktok,
        peekBytes: 64 * 1024,
        targetRxSpeed: 40_000
    )
    static let twitter = App(
        id: .twitter,
        peekBytes: 32 * 1024,
        targetRxSpeed: 40_000
    )
    static let youtube = App(
        id: .youtube,
        peekBytes: 16 * 1024,
        targetRxSpeed: 40_000
    )
}
