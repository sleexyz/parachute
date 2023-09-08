//
//  EnvironmentObjectProxy.swift
//  slowdown
//
//  Created by Sean Lee on 2/20/23.
//

import Foundation
import SwiftUI

struct EnvironmentObjectProxy<T: ObservableObject, Content: View>: View {
    let type: T.Type
    let content: (T) -> Content
    @EnvironmentObject private var obj: T
    var body: some View {
        content(obj)
    }
}
