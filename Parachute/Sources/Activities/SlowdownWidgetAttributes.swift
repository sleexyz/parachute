import ActivityKit 
import Foundation
import ProxyService
import Models

public struct SlowdownWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {

        // Dynamic stateful properties about your activity go here!
        public var settings: Proxyservice_Settings
        public var isConnected: Bool

        public init(settings: Proxyservice_Settings, isConnected: Bool) {
            self.settings = settings
            self.isConnected = isConnected 
        }


        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            settings = try container.decode(Proxyservice_Settings.self, forKey: .settings)
            isConnected = try container.decode(Bool.self, forKey: .isConnected)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(settings, forKey: .settings)
            try container.encode(isConnected, forKey: .isConnected)
        }

        enum CodingKeys: String, CodingKey {
            case settings
            case isConnected
        }
    }

    // Fixed non-changing properties about your activity go here:
    public init() {
    }
}
