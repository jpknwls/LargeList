//
//  ListView.swift
//  LargeList
//
//  Created by John Knowles on 6/24/24.
//


import SwiftUI

struct ListView: View {
    let coordinator: Coordinator
    
    @State var displayedCells = [Cell]()
    @State var state = ScrollState()

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear
                .contentShape(Rectangle())
                .overlay(gestures)
            
            ForEach(displayedCells) { cell in
                CellView(cell: cell)
            }
            .offset(y: state.offset)
        }
        .onReceive(coordinator.displayedCells, perform: { update in
            displayedCells = update
        })
        .onReceive(coordinator.scrollState, perform: {  update in
            withAnimation(update.animation) {
                state = update.state
            }
        })
        .id("org.LargeList.ListView")
    }
    
    @ViewBuilder var gestures: some View {
        ScrollGestures(coordinator: coordinator)
    }
}
