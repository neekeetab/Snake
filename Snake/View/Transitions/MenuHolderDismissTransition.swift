import UIKit

class MenuHolderDismissTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let menuViewController = transitionContext.viewController(forKey: .from) as? MenuHolderViewController else {
            fatalError("internal inconsistency")
        }
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            menuViewController.backgroundVisualEffectView.effect = nil
            menuViewController.contentView.center = CGPoint(x: menuViewController.contentView.center.x, y: menuViewController.contentView.center.y + UIScreen.main.bounds.size.height)
        }, completion: { _ in
            transitionContext.completeTransition(true)
        })
        
    }
    
}
