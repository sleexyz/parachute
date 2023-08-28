//
//  SlowdownWidgetLiveActivity.swift
//  SlowdownWidget
//
//  Created by Sean Lee on 8/2/23.
//

import ActivityKit
import WidgetKit
import SwiftUI
import Activities
import Controllers
import CommonLoaders
import ProxyService
import SwiftProtobuf

struct SlowdownWidgetLiveActivityView: View {
    var isStale: Bool
    var contentState: SlowdownWidgetAttributes.ContentState

    var body: some View {
        SlowdownWidgetView(
            settings: contentState.settings
        )
    }
}

struct SlowdownWidgetLiveActivity: Widget {
    init() {
        try? SettingsStore.shared.load()
    }
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SlowdownWidgetAttributes.self) { context in
            SlowdownWidgetView(settings: context.state.settings)
                .activityBackgroundTint(Color.background)
                .padding([.leading, .trailing], 20)
                .activitySystemActionForegroundColor(.black)
            
        } dynamicIsland: { context in
            
            DynamicIsland {
                expandedContent()
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.settings.activePreset.id)")
            } minimal: {
                Text(context.state.settings.activePreset.id)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
    @DynamicIslandExpandedContentBuilder
    private func expandedContent() -> DynamicIslandExpandedContent<some View> {
        // Expanded UI goes here.  Compose the expanded UI through
        // various regions, like leading/trailing/center/bottom
        DynamicIslandExpandedRegion(.leading) {
            Text("Leading")
        }
        DynamicIslandExpandedRegion(.trailing) {
            Text("Trailing")
        }
        DynamicIslandExpandedRegion(.bottom) {
            Text("Bottom ")
            // more content
        }

    }
}

extension SlowdownWidgetAttributes {
   fileprivate static var preview: SlowdownWidgetAttributes {
       SlowdownWidgetAttributes()
   }
}



extension SlowdownWidgetAttributes.ContentState {
   fileprivate static var focus: SlowdownWidgetAttributes.ContentState {
       SlowdownWidgetAttributes.ContentState(settings: .focus)
    }
    
    fileprivate static var relax: SlowdownWidgetAttributes.ContentState {
        SlowdownWidgetAttributes.ContentState(settings: .relax)
    }
}

//#Preview("Notification", as: .content, using: SlowdownWidgetAttributes.preview) {
//  SlowdownWidgetLiveActivity()
//} contentStates: {
//   SlowdownWidgetAttributes.ContentState.focus
//   SlowdownWidgetAttributes.ContentState.relax
//}
