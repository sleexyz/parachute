import ActivityKit 
import Foundation

public struct SlowdownWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        public var emoji: String
        public init(emoji: String) {
            self.emoji = emoji
        }
    }

    // Fixed non-changing properties about your activity go here!
    public var name: String

    public init(name: String) {
        self.name = name
    }
}