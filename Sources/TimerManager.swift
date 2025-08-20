import Foundation

/// Centralized timer management for coordinating city rotation and UI updates
final class TimerManager {
    private var timer: Timer?
    private var onTick: (() -> Void)?
    
    func start(interval: TimeInterval, tolerance: TimeInterval = 0.1, onTick: @escaping () -> Void) {
        stop()
        
        self.onTick = onTick
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.onTick?()
        }
        
        timer?.tolerance = tolerance
        
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        onTick = nil
    }
    
    deinit {
        stop()
    }
}