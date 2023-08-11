import ActivityKit 
import Foundation
import ProxyService
import Models

public struct SlowdownWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        public var settings: Proxyservice_Settings
        public init(settings: Proxyservice_Settings) {
            self.settings = settings
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self = try Self.init(settings: Proxyservice_Settings(from: container as! Decoder))
        }

        public func encode(to encoder: Encoder) throws {
            let container = encoder.singleValueContainer()
            try self.settings.encode(to: container as! Encoder)
        }
    }

    public init() {
    }

    // Fixed non-changing properties about your activity go here!
    // public var name: String

    // public init(name: String) {
    //     self.name = name
    // }
}
