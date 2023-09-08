//
//  Cardable.swift
//  slowdown
//
//  Created by Sean Lee on 2/22/23.
//

import Foundation
import SwiftUI

public protocol Cardable {
    associatedtype V: View
    func getID() -> String
    func getExpandedBody() -> AnyView
    @ViewBuilder func _makeCard(content: @escaping () -> AnyView) -> V
}

extension Cardable {
    func eraseToAnyCardable() -> AnyCardable {
        AnyCardable(cardable: self)
    }

    @ViewBuilder func makeCard(content: @escaping () -> some View) -> V {
        _makeCard {
            AnyView(content())
        }
    }
}

struct AnyCardable: Identifiable, Cardable {
    func _makeCard(content: @escaping () -> AnyView) -> AnyView {
        AnyView(cardable._makeCard {
            content()
        })
    }

    func getID() -> String {
        cardable.getID()
    }

    func getExpandedBody() -> AnyView {
        cardable.getExpandedBody()
    }

    typealias V = AnyView

    var cardable: any Cardable
    init(cardable: some Cardable) {
        self.cardable = cardable
    }

    var id: String {
        cardable.getID()
    }
}

extension AnyCardable: Hashable {
    static func == (lhs: AnyCardable, rhs: AnyCardable) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
