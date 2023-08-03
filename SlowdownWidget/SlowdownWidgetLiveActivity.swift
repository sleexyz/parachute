//
//  SlowdownWidgetLiveActivity.swift
//  SlowdownWidget
//
//  Created by Sean Lee on 8/2/23.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct SlowdownWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct SlowdownWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SlowdownWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension SlowdownWidgetAttributes {
    fileprivate static var preview: SlowdownWidgetAttributes {
        SlowdownWidgetAttributes(name: "World")
    }
}

extension SlowdownWidgetAttributes.ContentState {
    fileprivate static var smiley: SlowdownWidgetAttributes.ContentState {
        SlowdownWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: SlowdownWidgetAttributes.ContentState {
         SlowdownWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: SlowdownWidgetAttributes.preview) {
   SlowdownWidgetLiveActivity()
} contentStates: {
    SlowdownWidgetAttributes.ContentState.smiley
    SlowdownWidgetAttributes.ContentState.starEyes
}
