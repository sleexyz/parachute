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
    associatedtype T: ObservableObject
    func create() -> T
}

struct ProviderInner<T: ObservableObject>: ViewModifier {
    @State var value: T
    init(create: () -> T) {
        self._value = State(wrappedValue: create())
    }
    func body(content: Content) -> some View {
        return content.environmentObject(value)
    }
}


extension Dep {
    func body(content: Content) -> some View {
        return content.modifier(ProviderInner(create: create))
    }
}
