import ProxyService

var PEEK_BYTES = 16 * 1024

public struct App {
    public let appType: Proxyservice_AppType

    // How much to allow through before slowing down
    public var preSlowingBytes1: Int
    public var preSlowingBytes2: Int

    // How much to peek each time before injecting latency
    public var peekBytes: Int

    public var targetRxSpeed1: Double
    public var targetRxSpeed2: Double

    public var dropAllowedBytesUnusable: Int
    public var dropAllowedBytesBarelyUsable: Int
}

// Base settings for "barely usable" mode

public extension App {
    static let instagram = App(
        appType: .instagram,

        preSlowingBytes1: 1024,
        preSlowingBytes2: 16 * 1024,

        peekBytes: 2 * 1024,

        targetRxSpeed1: 4 * 1024,
        targetRxSpeed2: 24 * 1024,

        dropAllowedBytesUnusable: 16 * 1024,
        dropAllowedBytesBarelyUsable: 64 * 1024
    )
    static let tiktok = App(
        appType: .tiktok,

        preSlowingBytes1: 0,
        preSlowingBytes2: 1024,

        // preSlowingBytes: 0,
        peekBytes: 16 * 1024,

        targetRxSpeed1: 20000,
        targetRxSpeed2: 40000,

        dropAllowedBytesUnusable: 32 * 1024,
        dropAllowedBytesBarelyUsable: 64 * 1024
    )
    static let twitter = App(
        appType: .twitter,

        preSlowingBytes1: 0,
        preSlowingBytes2: 1024,

        peekBytes: 64 * 1024,

        targetRxSpeed1: 10000,
        targetRxSpeed2: 20000,

        dropAllowedBytesUnusable: 48 * 1024,
        dropAllowedBytesBarelyUsable: 64 * 1024
    )
    static let youtube = App(
        appType: .youtube,

        preSlowingBytes1: 0,
        preSlowingBytes2: 32 * 1024,

        peekBytes: 32 * 1024, // Lowered from 64 to 32 to prevent buffering

        targetRxSpeed1: 20000,
        targetRxSpeed2: 40000,

        dropAllowedBytesUnusable: 256 * 1024,
        dropAllowedBytesBarelyUsable: 256 * 1024
    )

    func preSlowingBytes(_ settings: Proxyservice_Settings) -> Int {
        if settings.usability == .unusable {
            return preSlowingBytes1
        }
        return preSlowingBytes2
    }

    func targetRxSpeed(_ settings: Proxyservice_Settings) -> Double {
        if settings.usability == .unusable {
            return targetRxSpeed1
        }
        return targetRxSpeed2
    }
}

public extension Proxyservice_Settings {
    func dropAllowedBytes(app: App) -> Int {
        if usability == .unusable {
            return app.dropAllowedBytesUnusable
        }
        return app.dropAllowedBytesBarelyUsable
    }
}
