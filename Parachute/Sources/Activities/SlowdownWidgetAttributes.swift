import ActivityKit
import Foundation
import Models
import ProxyService

public struct SlowdownWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        public var settings: Proxyservice_Settings?
        public var isConnected: Bool

        public init(settings: Proxyservice_Settings?, isConnected: Bool) {
            self.settings = settings
            self.isConnected = isConnected
            // do {
            //     let jsonData = try JSONEncoder().encode(self)
            //     if let jsonString = String(data: jsonData, encoding: .utf8) {
            //         print("json string: \(jsonString)")
            //     }
            // } catch {
            //     print("Error encoding SlowdownWidgetAttributes to JSON: \(error)")
            // }
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            settings = try container.decodeIfPresent(Proxyservice_Settings.self, forKey: .settings)
            isConnected = try container.decode(Bool.self, forKey: .isConnected)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(settings, forKey: .settings)
            try container.encode(isConnected, forKey: .isConnected)
        }

        enum CodingKeys: String, CodingKey {
            case settings
            case isConnected
        }
    }

    // Fixed non-changing properties about your activity go here:
    public init() {}
}
