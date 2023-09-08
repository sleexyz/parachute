import ProxyService

var PEEK_BYTES = 16 * 1024

public struct App {
    public let appType: Proxyservice_AppType
    // How much to allow through before slowing down
    public var preSlowingBytes: Int

    // How much to peek each time before injecting latency
    public var peekBytes: Int

    public var targetRxSpeed: Double

    public var allowedBytesBeforeDrop: Int
}

// Base settings for "barely usable" mode

public extension App {
    static let instagram = App(
        appType: .instagram,
        preSlowingBytes: 128 * 1024,
        peekBytes: 64 * 1024,
        targetRxSpeed: 25000,
        allowedBytesBeforeDrop: 128 * 1024
    )
    static let tiktok = App(
        appType: .tiktok,
        preSlowingBytes: 64 * 1024,
        peekBytes: 64 * 1024,
        targetRxSpeed: 20000,
        allowedBytesBeforeDrop: 64 * 1024
    )
    static let twitter = App(
        appType: .twitter,
        preSlowingBytes: 1024,
        peekBytes: 64 * 1024,
        targetRxSpeed: 10000,
        allowedBytesBeforeDrop: 48 * 1024
    )
    static let youtube = App(
        appType: .youtube,
        preSlowingBytes: 32 * 1024,
        peekBytes: 32 * 1024, // Lowered from 64 to 32 to prevent buffering
        targetRxSpeed: 20000,
        allowedBytesBeforeDrop: 256 * 1024
    )
}
