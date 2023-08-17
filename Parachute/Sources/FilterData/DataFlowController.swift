import NetworkExtension
import Logging
import SwiftProtobuf
import SwiftProtobufPluginLibrary
import ProxyService

public class DataFlowController {
    let logger: Logger = Logger(label: "industries.strange.slowdown.DataFlowController")
    
    let settings: Proxyservice_Settings

    public init(settings: Proxyservice_Settings) {
        logger.info("DataFlowController init")
        self.settings = settings
    }

    public func updateSettings(settings: Proxyservice_Settings) {
        logger.info("updateSettings: \(settings.debugDescription)")
    }

    public func matchSocialMedia(flow: NEFilterFlow) -> Bool {
        if flow.sourceAppIdentifier?.hasSuffix(".com.zhiliaoapp.musically") ?? false {
            return true
        }
        if flow.sourceAppIdentifier?.hasSuffix(".com.burbn.instagram") ?? false {
            return true
        }
        if flow.sourceAppIdentifier?.hasSuffix(".com.atebits.Tweetie2") ?? false {
            return true
        }
        return false
    }

    public func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        logger.info("New flow: \(flow)")
        if matchSocialMedia(flow: flow) {
            logger.info("Matched social media")
            return .allow()
        }
        return .allow()
    }
}
