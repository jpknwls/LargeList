//
//  ScrollGesturrs.swift
//  LargeList
//
//  Created by John Knowles on 6/24/24.
//

import SwiftUI

struct ScrollGestures: UIViewRepresentable {
    let coordinator: Coordinator
    func makeUIView(context: Context) -> some UIView {
        let v = UIView()
        let pan = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.scroll))
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tap))
        v.addGestureRecognizer(pan)
        v.addGestureRecognizer(tap)
        return v
    }
    
    func makeCoordinator() -> Coordinator {
        coordinator
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

