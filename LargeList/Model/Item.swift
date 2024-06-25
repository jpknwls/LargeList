//
//  Item.swift
//  LargeList
//
//  Created by John Knowles on 6/24/24.
//


import SwiftUI

struct Item:  Hashable {
    let id = UUID()
    let color: Color
    
    
    static let Default: Item = .init(color: .blue)
    
    static func list(count: Int = 10000) -> [Item] {
      var array = [Item]() //Array.init(repeating: Item.Default, count: count)
        for i in 0..<count {
            let color = [Color.red, Color.orange, Color.yellow, Color.blue, Color.green, Color.purple].randomElement() ?? .blue
//            array[i] = .init(color: color)
            array.append(.init(color: color))
        }
        return array
    }
}
import Foundation
