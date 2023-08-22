var PEEK_BYTES = 16 * 1024

public enum AppId {
    case instagram
    case tiktok
    case twitter
    case youtube
}

public struct App {
    public let id: AppId
    public var peekBytes: Int

    // For DroppingAppFlowController only
    public var preSlowingBytes: Int

    public var targetRxSpeed: Double
    public var sleepTime: UInt32
}

public extension App {
    static let instagram = App(
        id: .instagram,
        peekBytes: PEEK_BYTES,
        preSlowingBytes: 512 * 1024,
        targetRxSpeed: 20_000,
        sleepTime: UInt32(40_000)
    )
    static let tiktok = App(
        id: .tiktok,
        peekBytes: PEEK_BYTES,
        preSlowingBytes: 64 * 1024,
        targetRxSpeed: 10_000,
        sleepTime: UInt32(40_000)
    )
    static let twitter = App(
        id: .twitter,
        peekBytes: 1600,
        preSlowingBytes: 32 * 1024,
        targetRxSpeed: 10_000,
        sleepTime: UInt32(120_000)
    )
    static let youtube = App(
        id: .youtube,
        peekBytes: PEEK_BYTES,
        preSlowingBytes: 16 * 1024,
        targetRxSpeed: 10_000,
        sleepTime: UInt32(40_000) // 40ms sleep
    )
}
