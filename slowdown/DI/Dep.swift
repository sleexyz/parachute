//
//  Dep.swift
//  slowdown
//
//  Created by Sean Lee on 1/27/23.
//

import Foundation
import SwiftUI

extension View {
    func provideDeps(_ deps: [any Dep]) -> some View {
        self.modifier(Provider(deps: deps))
    }
    func consumeDep<T: ObservableObject>(_ type: T.Type, effect: @escaping (T) -> ()) -> some View {
        self.modifier(Consumer(type: type, effect: effect))
    }
}

protocol Dep {
    associatedtype T: ObservableObject
    func create(r: Registry) -> T
    func getServiceKeys() -> [ServiceKey]
    func environmentObject<Content: View>(registry: Registry, content: Content) -> any View
}

extension Dep {
    func getServiceKeys() -> [ServiceKey] {
        return [ServiceKey(serviceType: T.self)]
    }
    func environmentObject<Content: View>(registry: Registry, content: Content) -> any View {
        return content.environmentObject(registry.resolve(T.self))
    }
}

// A MockDep allows binding for a mock type (MockT) as well as the mocked type (T).

protocol MockDep: Dep {
    associatedtype MockT: ObservableObject
}

extension MockDep {
    func getServiceKeys() -> [ServiceKey] {
        return [
            ServiceKey(serviceType: MockT.self),
            ServiceKey(serviceType: T.self)
        ]
    }
    func environmentObject<Content: View>(registry: Registry, content: Content) -> any View {
        return content
            .environmentObject(registry.resolve(MockT.self))
            .environmentObject(registry.resolve(T.self))
    }
}
