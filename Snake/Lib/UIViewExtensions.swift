import UIKit
import ReactiveSwift
import ReactiveCocoa

fileprivate var blockingActivityIndicatorViewKey: UInt8 = 0
fileprivate extension UIView {
    
    var blockingActivityIndicatorView: BlockingActivityIndicatorView {
        get {
            return associatedObject(base: self, key: &blockingActivityIndicatorViewKey) {
                let blockingAI = BlockingActivityIndicatorView(frame: bounds)
                addSubview(blockingAI)
                bringSubview(toFront: blockingAI)
                return blockingAI
            }
        }
        set {
            associateObject(base: self, key: &blockingActivityIndicatorViewKey, value: newValue)
        }
        
    }
    
}

extension Reactive where Base: UIView {
    
    /// Blocks view with activity indicator
    public var isBlockedWithActivityIndicator: BindingTarget<Bool> {
        return makeBindingTarget {
            if $1 {
                $0.bringSubview(toFront: $0.blockingActivityIndicatorView)
                $0.blockingActivityIndicatorView.isHidden = false
                $0.blockingActivityIndicatorView.startAnimating()
            } else {
                $0.blockingActivityIndicatorView.stopAnimating()
                $0.blockingActivityIndicatorView.isHidden = true
            }
        }
    }
    
}
