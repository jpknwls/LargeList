//
//  Coordinator.swift
//  LargeList
//
//  Created by John Knowles on 6/24/24.
//


import SwiftUI
import Combine

class Coordinator: NSObject, UIGestureRecognizerDelegate {
    init(count: Int) {
       items = Item.list(count: count)
        locations = Array(0..<count).map { Location(index: $0,
                                                    offset: 0,
                                                    height: CGFloat.random(in: 40...300))}
    }
    
    private var items: [Item] = []
    private var locations: [Location] = []
    
    private var rangeLength = 40
    private var range: ClosedRange<Int> = 0...0
    var displayedCells = CurrentValueSubject<[Cell], Never>([])
    
    let scrollState = PassthroughSubject<ScrollStateUpdate, Never>()
    
    private var _offset = CGFloat.zero
    private var initialOffset: CGFloat? = nil
    
    private var contentOffsetBounds: CGRect {
         let width: CGFloat = 0
         let height = totalHeight - (frameHeight ?? 0)
         return CGRect(x: 0, y: 0, width: 0, height: -height)
     }
     
     private var contentOffset: CGPoint {
         return CGPoint(x: 0, y: _offset)
     }
    
    var frameHeight: CGFloat? = nil
    

    var scrollDragMode: DragMode = .default
    var scrollBarDragMode: DragMode = .default
    enum DragMode {
        case `default`
        case scroll(initial: CGFloat)
    }
    
    var lastScrollPan: Date? = nil
    var lastScrollBarPan: Date? = nil
    var contentOffsetAnimation: TimerAnimation?
            

    let scrollBarAnimationDuration: Double = 1 / 60
    
    var maxIndex: Int { items.count - 1 }
    var halfRange: Int { rangeLength / 2 }
    var totalHeight: CGFloat {
        guard let last = locations.last else { return 0 }
        return last.offset + last.height
    }
    
    
    
    let scrollQueue = DispatchQueue(label: "org.LargeLists.ScrollQueue", qos: .userInteractive)
    let itemsQueue = DispatchQueue(label: "org.LargeLists.ItemQueue", qos: .userInteractive)
    let locationsQueue = DispatchQueue(label: "org.LargeLists.ItemQueue", qos: .userInteractive)
    
    
    var cancellables = Set<AnyCancellable>()

 

    func setup() {
        range = 0...rangeLength
        updateLocations() {
            self.updateDisplayedItems(self._offset, force: true)
        }
    }
    
    
    
    @objc func scrollBar(gesture: UIPanGestureRecognizer) {
        let newPan = Date()

        switch gesture.state {
        case .began:
            stopScrollDeceleration()
            break
        case .changed:
            if let height = gesture.view?.frame.height {
                let location = gesture.location(in: gesture.view).y
                let position = max(min(location / height, 1), 0)
                
                let offset = (totalHeight - (frameHeight ?? 0)) * position

                handleOffsetChange(-offset, animation: .easeInOut(duration: scrollBarAnimationDuration))
            }
            break
        case .ended:
            let userHadStoppedDragging = newPan.timeIntervalSince(lastScrollBarPan ?? newPan) >= 0.1
            let velocity: CGPoint = userHadStoppedDragging ? .zero : gesture.velocity(in: gesture.view)

            completeGesture(withVelocity: -velocity)
            break
        default: break
            
        }
        
        lastScrollBarPan = newPan

    }
    
    @objc func tap(gesture: UITapGestureRecognizer) {
        if contentOffsetAnimation != nil {
            stopScrollDeceleration()
        } else {
            let offset = -gesture.location(in: gesture.view).y + _offset
            let index = index(for: offset)
            updateCellHeight(at: index, height: CGFloat.random(in: 40...300))
        }
    }

    
    @objc func scroll(gesture: UIPanGestureRecognizer) {
        let newPan = Date()
        
        switch gesture.state {
        case .began:
            stopScrollDeceleration()
            scrollDragMode = .scroll(initial: _offset)
            break
        case .changed:
            switch scrollDragMode {
            case .default: break
            case .scroll(initial: let initial):
                let translation = gesture.translation(in: gesture.view).y
                let newOffset = initial + translation
                handleOffsetChange(newOffset)
            }
        case .ended:
            scrollDragMode = .default
            let userHadStoppedDragging = newPan.timeIntervalSince(lastScrollPan ?? newPan) >= 0.1
            let velocity: CGPoint = userHadStoppedDragging ? .zero : gesture.velocity(in: gesture.view)
            completeGesture(withVelocity: velocity)

            
        case .failed, .cancelled:
            scrollDragMode = .default
        default: break
        }
        
        lastScrollPan = newPan
    }
    
  
    
    func updateCellHeight(at index: Int, height: CGFloat) {
        guard index > 0 && index < items.count else { return }
        locations[index].height = height
        updateLocations() {
            self.updateDisplayedItems(self._offset, force: true)
        }
    }
    
    
    func updateScreenHeight(_ newHeight: CGFloat) {
        
        print("UPDATE SCREEN HEIGHT")
        frameHeight = newHeight
    }
    
    
    
    
    private func handleOffsetChange(_ newOffset: CGFloat,
                            animation: Animation? = nil) {
        _offset = newOffset
        updateScrollState(newOffset, animation: animation)
        updateDisplayedItems(newOffset)
        
    }
    
    
    
    private func updateScrollState(_ newOffset: CGFloat,
                           animation: Animation? = nil) {
        scrollQueue.async { [unowned self] in
            let frameHeight = (frameHeight ?? 0)
            let totalHeight = totalHeight
            
            var barHeight = (frameHeight / totalHeight)  * frameHeight
            barHeight = max(min(barHeight, frameHeight), 30)
            
            let percentage = -newOffset / (totalHeight - frameHeight)
            var barOffset = frameHeight * percentage
            barOffset = min(max(barOffset, 0), frameHeight - barHeight)
            
            DispatchQueue.main.async {
                self.scrollState.send(.init(state:.init(offset: newOffset,
                                                        barOffset: barOffset,
                                                        barHeight: barHeight),
                                            animation: animation))
            }
        }
    }
    
   private func updateDisplayedItems(_ newOffset: CGFloat, force: Bool  = false) {
       itemsQueue.async { [unowned self] in
                 
           
            let index = index(for: newOffset)
            
            let lower = max(min(index - halfRange, maxIndex), 0)
            let upper = max(min(index + halfRange, maxIndex), lower)
            let newRange = lower...upper
            
            
            if force || self.range != newRange {
                self.range = newRange
                
                let displayedItems = zip(items[newRange], locations[newRange])
                let displayedLocations = Array(locations[newRange])
                var counter = 0
                var  cells =  Array.init(repeating: Cell.Default, count: newRange.count)
                    for (item, location) in displayedItems {
                    cells[counter] = .init(item: item,
                                           location: location )
                    counter += 1
                }
                
                DispatchQueue.main.async {
                    self.displayedCells.value = cells
                }
            }
            
        }
        

    }

    private func updateLocations(completion: @escaping () -> () = { }) {
        locationsQueue.async { [weak self] in
            guard let self else { return }
            var tempLocations = [Location]()
            var counter = CGFloat.zero
            var index = 0
            for location in  locations {
                tempLocations.append(.init(index: index,
                                           offset: counter,
                                           height: location.height))
                                       
                counter += location.height
                index += 1
            }
            
            locations = tempLocations
            completion()
        }
    }
    
    private func bounce(withVelocity velocity: CGPoint) {
         let restOffset = contentOffset.clamped(to: contentOffsetBounds)
         let displacement = contentOffset - restOffset
         let threshold = 0.5 / UIScreen.main.scale
         let spring = Spring(mass: 1, stiffness: 100, dampingRatio: 1)
         
         let parameters = SpringTimingParameters(spring: spring,
                                                 displacement: displacement,
                                                 initialVelocity: velocity,
                                                 threshold: threshold)
        
         contentOffsetAnimation = TimerAnimation(
            duration: parameters.duration,
             animations: { [weak self] _, time in
                 let offset = restOffset.y + parameters.value(at: time).y
                 self?.handleOffsetChange(offset)

             })
     }

    
    func stopScrollDeceleration() {
        contentOffsetAnimation?.invalidate()
        contentOffsetAnimation = nil
    }
    
    func startDeceleration(withVelocity velocity: CGPoint) {
        
        let decelerationRate = UIScrollView.DecelerationRate.normal.rawValue
        let threshold = 0.5 / UIScreen.main.scale

        let parameters = DecelerationTimingParameters(
                            initialValue: contentOffset,
                            initialVelocity: velocity,
                            decelerationRate: decelerationRate,
                            threshold: threshold)
       
        let destination = parameters.destination
        let duration: TimeInterval
        var isBounce = false
        if destination.y > 0, let topDuration = parameters.duration(to: .init(x: 0, y: 0)) {
            duration = topDuration
            isBounce = true

        } else if destination.y < -contentOffsetBounds.height, let bottomDuration = parameters.duration(to: .init(x: 0, y: -contentOffsetBounds.height)) {
            duration = bottomDuration
            isBounce = true
        } else {
            duration = parameters.duration
        }

////
              contentOffsetAnimation = TimerAnimation(
                  duration: duration,
                  animations: { [weak self] _, time in
                      let offset = parameters.value(at: time).y
                      self?.handleOffsetChange(offset)
                  },
                  completion: { [weak self] finished in
                      guard finished && isBounce else { return }
                      print("BOUNCE")
                      let velocity = parameters.velocity(at: duration)
                      self?.bounce(withVelocity: velocity)
                  })

    }
   
    private func clampOffset(_ offset: CGPoint) -> CGPoint {
         let rubberBand = RubberBand(dims: .init(width: 0, height: totalHeight - (frameHeight ?? 0)), bounds: contentOffsetBounds)
         return rubberBand.clamp(offset)
     }
     
     private func completeGesture(withVelocity velocity: CGPoint) {
         if contentOffsetBounds.containsIncludingBorders(.init(x: 0, y: _offset)) {
             startDeceleration(withVelocity: velocity)
         } else {
             bounce(withVelocity: velocity)
         }
     }
    
    
    
    private func index(for offset: CGFloat) -> Int {
        guard let index = locations.lastIndex(where: {
            offset < -$0.offset
        }) else {
            return 0
        }
        
        return min(max(index, 0), items.count - 1)
    }

    
   

}
