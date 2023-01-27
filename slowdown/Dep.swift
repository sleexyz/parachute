//
//  Dep.swift
//  slowdown
//
//  Created by Sean Lee on 1/27/23.
//

import Foundation
import SwiftUI


struct Consumer<T: ObservableObject>: ViewModifier {
    let type: T.Type
    @EnvironmentObject private var obj: T
    let effect: (_ value: T) -> ()
    func body(content: Content) -> some View {
        return content.onAppear {
            effect(obj)
        }
    }
}

protocol Dep: ViewModifier {
    var value: T? { get nonmutating set }
    associatedtype T: ObservableObject
    
    func create() -> T
}

extension Dep {
    func body(content: Content)  -> some View {
        return self.bodyImpl(content: content)
    }
    func bodyImpl(content: Content)  -> some View {
        let _ = Self._printChanges()
        return Group {
            if value == nil {
                Rectangle().hidden()
            } else {
                content.environmentObject(value!)
            }
        }.onAppear {
            value = create()
        }
    }
}
