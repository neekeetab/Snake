import Foundation
import CoreMotion
import ReactiveSwift
import enum Result.NoError

class MotionManager {
    
    enum Rotation {
        case forth
        case back
        case left
        case right
        var opposite: Rotation {
            switch self {
            case .forth:
                return .back
            case .back:
                return .forth
            case .left:
                return .right
            case .right:
                return .left
            }
        }
    }
    
    static let shared = MotionManager()
    
    /// Sends rotation.
    let rotation: Signal<Rotation, NoError>
    
    private let motionManager = CMMotionManager()
    private let operationQueue = OperationQueue()
    
    init() {
        
        let (rotation, rotationObserver) = Signal<Rotation, NoError>.pipe()
        self.rotation = rotation
        
        motionManager.gyroUpdateInterval = 1.0/60.0
        
        motionManager.startDeviceMotionUpdates(using: .xArbitraryCorrectedZVertical, to: operationQueue) { deviceMotion, error in
            
            guard error == nil else {
                print("error: \(error!)")
                return
            }
            
            guard let deviceMotion = deviceMotion else {
                print("internal inconsistency")
                return
            }
            
            let gravity = deviceMotion.gravity
            
            let x = gravity.x
            let y = gravity.y
            let z = gravity.z
            
            // xz - (>0) ? left : right
            // yz - (>0) ? back : forth
            
            if (abs(x * z) > abs(x * y) && abs(x * z) > abs(y * z)) {
                rotationObserver.send(value: x * z > 0 ? .left : .right)
            } else {
                rotationObserver.send(value: y * z > 0 ? .back : .forth)
            }
            
        }
    }
    
}
