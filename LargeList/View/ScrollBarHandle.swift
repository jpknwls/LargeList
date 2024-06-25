//
//  ScrollBarHandle.swift
//  LargeList
//
//  Created by John Knowles on 6/24/24.
//

import SwiftUI


struct ScrollBarHandle: View {
    let coordinator: Coordinator
    
    @State var state = ScrollState()

    var body: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .frame(width: 6, height: state.barHeight)
            .padding(.trailing, 4)
            .offset(y: state.barOffset)
            .animation(.interactiveSpring, value:state.offset)
            .onReceive(coordinator.scrollState, perform: {  update in
                withAnimation(update.animation) {
                    state = update.state
                }
            })
    }
}




