//
//  ConnectedView.swift
//  slowdown
//
//  Created by Sean Lee on 2/15/23.
//

import Foundation
import SwiftUI
import ProxyService
import OrderedCollections
import Controllers
import AppViews
import CommonViews

struct ProfileCardModifier: ViewModifier {
    @EnvironmentObject var profileManager: ProfileManager
    
    func body(content: Content) -> some View {
        content
    }
}

struct ConnectedView: View {
    @EnvironmentObject var scrollSessionViewController: ScrollSessionViewController
    
    var body: some View {
        
        if scrollSessionViewController.open {
            ScrollSessionView(duration: 30)
        } else {
            MainView()
        }
    }
}

struct ConnectedView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectedPreviewContext {
            ConnectedView()
        }
    }
}
