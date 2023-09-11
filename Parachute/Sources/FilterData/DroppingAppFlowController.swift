import FilterCommon
import NetworkExtension
import OSLog
import ProxyService

class DroppingAppFlowController {
    let app: App

    public init(app: App) {
        self.app = app
    }

    func handleInboundData(from _: NEFilterFlow, offset: Int, readBytes: Data, settings: Proxyservice_Settings) -> NEFilterDataVerdict {
        let allowedBytesBeforeDrop = settings.dropAllowedBytes(app: app)

        if offset < allowedBytesBeforeDrop {
            return NEFilterDataVerdict(passBytes: readBytes.count, peekBytes: allowedBytesBeforeDrop)
        }
        return .drop()
    }

    static var instagram = DroppingAppFlowController(app: .instagram)
    static var tiktok = DroppingAppFlowController(app: .tiktok)
    static var twitter = DroppingAppFlowController(app: .twitter)
    static var youtube = DroppingAppFlowController(app: .youtube)

    static func getController(app: App) -> DroppingAppFlowController {
        switch app.appType {
        case .instagram:
            instagram
        case .tiktok:
            tiktok
        case .twitter:
            twitter
        case .youtube:
            youtube
        default:
            DroppingAppFlowController(app: app)
        }
    }
}
