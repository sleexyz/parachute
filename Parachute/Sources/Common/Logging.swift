import Logging
import LoggingOSLog

public struct CommonLogging {
    public static func initialize() {
        LoggingSystem.bootstrap(LoggingOSLog.init)
    }
}
