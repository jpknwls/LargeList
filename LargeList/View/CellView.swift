//
//  CellView.swift
//  LargeList
//
//  Created by John Knowles on 6/24/24.
//

import SwiftUI

struct CellView: View {
    let cell: Cell
    
    var body: some View {
        Text(String(cell.location.index))
            .font(Font.system(size: cell.location.height - 12))
                .tint(cell.item.color)
                .foregroundStyle(cell.item.color)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: cell.location.height)
                .padding(.horizontal, 16)
                .allowsHitTesting(false)
                .offset(y: cell.location.offset)
                .id(cell)
    }
}




