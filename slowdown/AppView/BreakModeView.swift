//
//  BreakModeView.swift
//  slowdown
//
//  Created by Sean Lee on 1/5/23.
//

import Foundation
import SwiftUI

struct BreakModeView: View {
    @EnvironmentObject var model: AppViewModel
    @EnvironmentObject var cheatController: CheatController
    
    
    var body: some View {
        var title = ""
        let t = Int(cheatController.sampledCheatTimeLeft.rounded(.up))
        let min = t / 60
        let sec = t % 60
        if min > 0 {
            title += "\(min)m"
        }
        if sec > 0 {
            if title != "" {
                title += " "
            }
            title += "\(sec)s"
        }
        return ZStack(alignment: .top) {
            Button(action: model.startCheat) {
                Text("🤤")
            }
            .font(.system(size: 144))
            .padding()
            .frame(maxWidth: .infinity)
            Text(title).padding().offset(x: 0, y: 200)
        }
    }
}

struct Previews_BreakModeView_Previews: PreviewProvider {
    static var previews: some View {
        BreakModeView()
            .provideDeps(previewDeps)
    }
}
