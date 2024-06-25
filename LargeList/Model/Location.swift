//
//  Location.swift
//  LargeList
//
//  Created by John Knowles on 6/24/24.
//

import Foundation

struct Location: Hashable {
    var index: Int
    var offset: CGFloat
    var height: CGFloat
    
    static let Default: Location = .init(index: 0,
                                     offset: 0,
                                     height: 60)

}
