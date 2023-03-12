//
//  Cardable.swift
//  slowdown
//
//  Created by Sean Lee on 2/22/23.
//

import Foundation
import SwiftUI

protocol Cardable {
    associatedtype V: View
    @ViewBuilder
    func makeCard() -> V
    func getID() -> String
}

extension Cardable {
    func eraseToAnyCardable() -> AnyCardable {
        return AnyCardable(cardable: self)
    }
}

struct AnyCardable: Identifiable, Cardable {
    func makeCard() -> AnyView {
        AnyView(self.cardable.makeCard())
    }
    
    func getID() -> String {
        self.cardable.getID()
    }
    
    typealias V = AnyView
    
    var cardable: any Cardable
    init<T>(cardable: T) where T: Cardable {
        self.cardable = cardable
    }
    
    var id: String {
        self.cardable.getID()
    }
}

extension AnyCardable: Hashable {
    static func == (lhs: AnyCardable, rhs: AnyCardable) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
