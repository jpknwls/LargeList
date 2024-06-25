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
//        let _ = print(cell.location.index)
        
        Text(String(cell.location.index))
            .font(Font.system(size: cell.location.height - 12))
//                .tint(cell.item.color)
                .foregroundStyle(cell.item.color)
                .frame(height: cell.location.height)
               .frame(maxWidth: .infinity, alignment: .leading)
//               .background {
//                   Color(UIColor.systemGray6)
//                       .padding(.vertical, 4)
//               }
               .padding(.horizontal, 16)
               .allowsHitTesting(false)
                .offset(y: cell.location.offset)
                .animation(.easeInOut(duration: 0.2), value: cell.location.height)
                .animation(.easeInOut(duration: 0.2), value: cell.location.offset)
                .transaction { transaction in
                    transaction.isContinuous = true
                }
                .id(cell.id)
    }
}




