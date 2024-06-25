//
//  Cell.swift
//  LargeList
//
//  Created by John Knowles on 6/24/24.
//

import Foundation

struct Cell: Identifiable, Hashable {
    let item: Item
    let location: Location
    
    var id: UUID { item.id }
    
    static let Default: Cell = .init(item: .Default,
                                     location: .Default)

}

