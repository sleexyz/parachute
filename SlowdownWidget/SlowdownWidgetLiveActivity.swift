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
import CommonViews
import SwiftProtobuf

struct SlowdownWidgetLiveActivity: Widget {
    init() {
        try? SettingsStore.shared.load()
    }
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SlowdownWidgetAttributes.self) { context in
            SlowdownWidgetView(settings: context.state.settings, isConnected: context.state.isConnected)
                .activityBackgroundTint(Color.background.opacity(0.5))
                // .activityBackgroundTint(.ultraThinMaterial)
                .padding([.leading, .trailing], 20)
                .activitySystemActionForegroundColor(.white)
            
        } dynamicIsland: { context in
            
            DynamicIsland {
                expandedContent()
            } compactLeading: {
                EmptyView()
            } compactTrailing: {
                EmptyView()
            } minimal: {
                EmptyView()
            }
        }
    }
    @DynamicIslandExpandedContentBuilder
    private func expandedContent() -> DynamicIslandExpandedContent<some View> {
        // Expanded UI goes here.  Compose the expanded UI through
        // various regions, like leading/trailing/center/bottom
        DynamicIslandExpandedRegion(.leading) {
            EmptyView()
        }

        DynamicIslandExpandedRegion(.trailing) {
            EmptyView()
        }

        DynamicIslandExpandedRegion(.bottom) {
            EmptyView()
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
       SlowdownWidgetAttributes.ContentState(settings: .focus, isConnected: true)
    }
    
    fileprivate static var relax: SlowdownWidgetAttributes.ContentState {
        SlowdownWidgetAttributes.ContentState(settings: .relax, isConnected: true)
    }
}

//#Preview("Notification", as: .content, using: SlowdownWidgetAttributes.preview) {
//  SlowdownWidgetLiveActivity()
//} contentStates: {
//   SlowdownWidgetAttributes.ContentState.focus
//   SlowdownWidgetAttributes.ContentState.relax
//}
