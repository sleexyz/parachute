import NetworkExtension
import Logging
import SwiftProtobuf
import ProxyService

let PEEK_SIZE = 1024

public class DataFlowController {
    let logger: Logger = Logger(label: "industries.strange.slowdown.DataFlowController")
    
    var settings: Proxyservice_Settings

    public init(settings: Proxyservice_Settings) {
        logger.info("DataFlowController init")
        self.settings = settings
    }

    public func updateSettings(settings: Proxyservice_Settings) {
        self.settings = settings
        logger.info("updated settings: \(settings.debugDescription)")
    }

    public func matchSocialMedia(flow: NEFilterFlow) -> Bool {
        if flow.sourceAppIdentifier?.hasSuffix(".com.zhiliaoapp.musically") ?? false {
            return true
        }
        if flow.sourceAppIdentifier?.hasSuffix(".com.burbn.instagram") ?? false {
            // Check if is NEFilterSocketFlow
            if let flow = flow as? NEFilterSocketFlow {
                if flow.remoteHostname?.hasPrefix("chat-e2ee") ?? false {
                    return false
                }
                if flow.remoteHostname?.hasPrefix("mqtt.") ?? false {
                    return false
                }
            }
            return true
        }
        if flow.sourceAppIdentifier?.hasSuffix(".com.atebits.Tweetie2") ?? false {
            return true
        }
        return false
    }

    var shouldAllowSocialMedia: Bool {
        return settings.activePreset.baseRxSpeedTarget == .infinity
    }

    public func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        logger.info("New flow: \(flow)")
        if matchSocialMedia(flow: flow) {
            return .filterDataVerdict(withFilterInbound: true, peekInboundBytes: PEEK_SIZE,  filterOutbound: false, peekOutboundBytes: 0)
        }
        return .allow()
    }

    public func handleInboundData(from flow: NEFilterFlow, readBytesStartOffset offset: Int, readBytes: Data) -> NEFilterDataVerdict {
        if shouldAllowSocialMedia {
            // logger.info("Allowing social media")
            return NEFilterDataVerdict(passBytes: readBytes.count, peekBytes: PEEK_SIZE)
        } else {
            // logger.info("Blocking social media")
            return .drop()
        }
    }
}
