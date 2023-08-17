import ProxyService
import Logging
import LoggingOSLog
import NetworkExtension
import Common

public class FilterConfigurationUpdateHandler {
    let logger = {
        LoggingSystem.bootstrap(LoggingOSLog.init)
        return Logger(label: "industries.strange.slowdown.FilterConfigurationUpdateHandler")
    }()

    weak var provider: NEFilterControlProvider? = nil

    public init() {}

    public func registerProvider(provider: NEFilterControlProvider) {
        self.provider = provider
    }

    public func update(filterConfiguration: NEFilterProviderConfiguration) {
        guard let data = filterConfiguration.vendorConfiguration?["slowdown-settings"] else {
            logger.error("did not receive any data, aborting update")
            return
        }
        guard let settings = try? Proxyservice_Settings(serializedData: data as! Data) else {
            logger.error("could not deserialize settings, aborting update")
            return
        }
        logger.info("received update! \(settings)")
        provider?.notifyRulesChanged()
    }

}
