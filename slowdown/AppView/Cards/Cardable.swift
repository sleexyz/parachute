//
//  Cardable.swift
//  slowdown
//
//  Created by Sean Lee on 2/22/23.
//

import Foundation
import SwiftUI

protocol Cardable: Identifiable {
    associatedtype V: View
    @ViewBuilder
    func makeCard() -> V
}

