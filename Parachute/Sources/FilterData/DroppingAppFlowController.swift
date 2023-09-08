import FilterCommon
import NetworkExtension
import OSLog

class DroppingAppFlowController {
    let app: App

    public init(app: App) {
        self.app = app
    }

    func handleInboundData(from _: NEFilterFlow, offset: Int, readBytes: Data) -> NEFilterDataVerdict {
        if offset < app.allowedBytesBeforeDrop {
            return NEFilterDataVerdict(passBytes: readBytes.count, peekBytes: app.allowedBytesBeforeDrop)
        }
        return .needRulesBlocking()
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
