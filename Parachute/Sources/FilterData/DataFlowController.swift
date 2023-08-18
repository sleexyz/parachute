import NetworkExtension
import Logging
import SwiftProtobuf
import SwiftProtobufPluginLibrary
import ProxyService

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
            if shouldAllowSocialMedia {
                logger.info("Allowing social media")
                return .allow()
            } else {
                logger.info("Blocking social media")
                return .drop()
            }
        }
        return .allow()
    }
}
