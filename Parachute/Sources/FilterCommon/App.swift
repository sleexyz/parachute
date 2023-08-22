

public enum AppId {
    case instagram
    case tiktok
    case twitter
}

public struct App {
    public let id: AppId
}

public extension App {
    static let instagram = App(id: .instagram)
    static let tiktok = App(id: .tiktok)
    static let twitter = App(id: .twitter)
}