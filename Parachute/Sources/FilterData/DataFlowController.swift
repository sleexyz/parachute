import NetworkExtension
import SwiftProtobuf
import ProxyService
import OSLog
import FilterCommon

public class DataFlowController {
    let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "DataFlowController")

    var settings: Proxyservice_Settings

    weak var provider: NEFilterDataProvider?

    var instagram = AppFlowController(app: .instagram)
    var tiktok = AppFlowController(app: .tiktok)
    var twitter = AppFlowController(app: .twitter)
    var youtube = AppFlowController(app: .youtube)

    public init(settings: Proxyservice_Settings) {
        logger.info("DataFlowController init")
        self.settings = settings
    }

    public func updateSettings(settings: Proxyservice_Settings) {
        self.settings = settings
        logger.info("updated settings: \(settings.debugDescription, privacy: .public)")
    }

    public func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        // logger.info("New flow: \(flow)")
        guard let app = flow.matchSocialMedia() else {
            return .allow()
        }

        // Pass to handleInboundData
        return .filterDataVerdict(withFilterInbound: true, peekInboundBytes: app.peekBytes,  filterOutbound: false, peekOutboundBytes: 0)
    }

    public func handleInboundData(from flow: NEFilterFlow, offset: Int, readBytes: Data) -> NEFilterDataVerdict {
        guard let app = flow.matchSocialMedia() else {
            return .allow()
        }
        if settings.shouldAllowSocialMedia {
            return .allowPeekBytes(passBytes: readBytes.count, app: app)
        }
        switch app.id {
        case .instagram:
            return instagram.handleInboundData(from: flow, offset: offset, readBytes: readBytes)
        case .tiktok:
            return tiktok.handleInboundData(from: flow, offset: offset, readBytes: readBytes)
        case .twitter:
            return twitter.handleInboundData(from: flow, offset: offset, readBytes: readBytes)
        case .youtube:
            return youtube.handleInboundData(from: flow, offset: offset, readBytes: readBytes)
        }
    }
}
