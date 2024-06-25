//
//  ScrollBarGestures.swift
//  LargeList
//
//  Created by John Knowles on 6/24/24.
//

import SwiftUI


struct ScrollBarGestures: UIViewRepresentable {
    let coordinator: Coordinator
    func makeUIView(context: Context) -> some UIView {
        let v = UIView()
        let pan = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.scrollBar))
        v.addGestureRecognizer(pan)
        
        return v
    }
    
    func makeCoordinator() -> Coordinator {
        coordinator
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
    
}
