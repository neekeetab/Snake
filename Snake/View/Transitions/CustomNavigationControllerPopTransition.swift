import UIKit

class CustomNavigationControllerPopTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to) else {
            print("internal inconsistency")
            return
        }
        
        let container = transitionContext.containerView
        
        let viewHeight = container.frame.size.height
        
        container.addSubview(toView)
        toView.frame.origin.y -= viewHeight
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            
            fromView.frame.origin.y += viewHeight
            toView.frame.origin.y += viewHeight
            
        }) { _ in
            let success = !transitionContext.transitionWasCancelled
            if !success {
                toView.removeFromSuperview()
            }
            transitionContext.completeTransition(success)
        }
    }
    
}
