import NetworkExtension
import SwiftProtobuf
import ProxyService
import OSLog
import FilterCommon

let PEEK_SIZE = 128 * 1024 

public class DataFlowController {
    let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "DataFlowController")

    var settings: Proxyservice_Settings

    weak var provider: NEFilterDataProvider?

    var instagram = AppFlowController(appId: .instagram, targetRxSpeed: 40_000)
    var tiktok = AppFlowController(appId: .tiktok, targetRxSpeed: 40_000)
    var twitter = AppFlowController(appId: .twitter, targetRxSpeed: 40_000)

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
        guard flow.matchSocialMedia() != nil  else {
            return .allow()
        }

        // Pass to handleInboundData
        return .filterDataVerdict(withFilterInbound: true, peekInboundBytes: PEEK_SIZE,  filterOutbound: false, peekOutboundBytes: 0)
    }

    public func handleInboundData(from flow: NEFilterFlow, offset: Int, readBytes: Data) -> NEFilterDataVerdict {
        let allowVerdict = NEFilterDataVerdict(passBytes: readBytes.count, peekBytes: PEEK_SIZE)
       guard let app = flow.matchSocialMedia() else {
           return .allow()
       }
        if settings.shouldAllowSocialMedia {
            return allowVerdict
        }
       switch app.id {
           case .instagram:
               return instagram.handleInboundData(from: flow, offset: offset, readBytes: readBytes)
           case .tiktok:
               return tiktok.handleInboundData(from: flow, offset: offset, readBytes: readBytes)
           case .twitter:
               return twitter.handleInboundData(from: flow, offset: offset, readBytes: readBytes)
       }
    }
}
