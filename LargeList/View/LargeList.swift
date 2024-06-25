//
//  LargeList.swift
//  LargeList
//
//  Created by John Knowles on 6/24/24.
//


import SwiftUI
import Combine

struct LargeList: View {
    
    init(count: Int) {
        self.coordinator = Coordinator(count: count)
    }
    
    let coordinator: Coordinator
    
    
    var body: some View {
        GeometryReader { geo  in
            ListView(coordinator: coordinator)
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity,
                   alignment: .top)
            .overlay {
                ScrollBarHandle(coordinator: coordinator)
                .frame(maxWidth: .infinity, maxHeight: .infinity,  alignment:.topTrailing)
            }
            .overlay(alignment: .topTrailing)  {
                Color.clear
                    .frame(width: 20)
                    .contentShape(Rectangle())
                    .overlay {
                        ScrollBarGestures(coordinator: coordinator)
                    }
            }
            .onAppear {
                coordinator.updateScreenHeight(geo.size.height)
                coordinator.setup()
            }
            .onChange(of: geo.size.height, perform: coordinator.updateScreenHeight)
        }
    }
    
}
