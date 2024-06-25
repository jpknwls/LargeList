import QuartzCore

//public final class TimerAnimation {
//
//    public typealias Animations = (_ offset: CGSize) -> Void
//    public typealias Completion = (_ finished: Bool) -> Void
//    
//    public init(parameters: TimingParameters,
//                animations: @escaping Animations,
//                completion: Completion? = nil) {
//        self.parameters  = parameters
//        self.animations = animations
//        self.completion = completion
//
//        firstFrameTimestamp = CACurrentMediaTime()
//        
//        let displayLink = CADisplayLink(target: self, selector: #selector(handleFrame(_:)))
//        displayLink.add(to: .main, forMode: RunLoop.Mode.common)
//        self.displayLink = displayLink
//    }
//
//    deinit {
//        invalidate()
//    }
//    
//    public func invalidate() {
//        guard running else { return }
//        running = false
//        completion?(false)
//        displayLink?.invalidate()
//    }
//
//    private let parameters: TimingParameters
//    private let animations: Animations
//    private let completion: Completion?
//    private weak var displayLink: CADisplayLink?
//
//    private var running: Bool = true
//
//    private let firstFrameTimestamp: CFTimeInterval
//
//    @objc private func handleFrame(_ displayLink: CADisplayLink) {
//        guard running else { return }
//        let elapsed = CACurrentMediaTime() - firstFrameTimestamp
//        if elapsed >= parameters.duration {
//            let offset = parameters.value(at: parameters.duration)
//            animations(CGSize(width: offset.x, height: offset.y))
//            running = false
//            completion?(true)
//            displayLink.invalidate()
//        } else {
//            let offset = parameters.value(at: elapsed)
//            animations(CGSize(width: offset.x, height: offset.y))
//        }
//    }
//}
//

public final class TimerAnimation {

    public typealias Animations = (_ progress: Double, _ time: TimeInterval) -> Void
    public typealias Completion = (_ finished: Bool) -> Void
    
    public init(duration: TimeInterval, animations: @escaping Animations, completion: Completion? = nil) {
        self.duration = duration
        self.animations = animations
        self.completion = completion

        firstFrameTimestamp = CACurrentMediaTime()
        
        let displayLink = CADisplayLink(target: self, selector: #selector(handleFrame(_:)))
        displayLink.add(to: .main, forMode: RunLoop.Mode.common)
        self.displayLink = displayLink
    }

    deinit {
        invalidate()
    }
    
    public func invalidate() {
        guard running else { return }
        running = false
        completion?(false)
        displayLink?.invalidate()
    }

    private let duration: TimeInterval
    private let animations: Animations
    private let completion: Completion?
    private weak var displayLink: CADisplayLink?

    private var running: Bool = true

    private let firstFrameTimestamp: CFTimeInterval

    @objc private func handleFrame(_ displayLink: CADisplayLink) {
        guard running else { return }
        let elapsed = CACurrentMediaTime() - firstFrameTimestamp
        if elapsed >= duration {
            animations(1, duration)
            running = false
            completion?(true)
            displayLink.invalidate()
        } else {
            animations(elapsed / duration, elapsed)
        }
    }
}
