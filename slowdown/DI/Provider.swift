//
//  Provider.swift
//  slowdown
//
//  Created by Sean Lee on 1/28/23.
//

import Foundation
import SwiftUI

// A Provider provides
// 1) services to views -- via EnvironmentObject
// 2) services to other provider-created services -- via a view-hierarchy bound Registry
struct Provider: ViewModifier {
    let deps: [any Dep]
    @Environment(\.registry) private var parent: Registry
    
    func body(content: Content) -> some View {
        content.modifier(ProviderInner(deps: deps, parent: parent))
    }
}

// We separate ProviderInner to allow instantiation of the dep immediately after the registry is fetched.
private struct ProviderInner: ViewModifier {
    @StateObject private var registry: RegistryImpl
    let deps: [any Dep]
    
    init(deps: [any Dep], parent: Registry) {
        self._registry = StateObject(wrappedValue: RegistryImpl(deps: deps, parent: parent))
        self.deps = deps
    }
    
    func body(content: Content) -> some View {
        content
            .modifier(ProviderViewer(deps: deps, registry: registry))
            .environment(\.registry, registry)
    }
}

internal struct ProviderViewer: ViewModifier {
    let deps: [any Dep]
    let registry: Registry
    
    func body (content: Content) -> some View {
        if deps.isEmpty {
            return AnyView(content)
        }
        return AnyView(AnyView(deps[0].environmentObject(registry: registry, content: content))
            .modifier(ProviderViewer(deps: Array(deps.dropFirst(1)), registry: registry)))
    }
}
