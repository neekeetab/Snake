import UIKit

class MenuHolderPresentTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let menuViewController = transitionContext.viewController(forKey: .to) as? MenuHolderViewController else {
            fatalError("internal inconsistency")
        }
        
        transitionContext.containerView.backgroundColor = .clear
        transitionContext.containerView.addSubview(menuViewController.view)
        menuViewController.backgroundVisualEffectView.effect = nil
        menuViewController.contentView.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.size.height)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            menuViewController.backgroundVisualEffectView.effect = UIBlurEffect(style: .dark)
            menuViewController.contentView.frame.origin = CGPoint.zero
            
        }, completion: { _ in
            transitionContext.completeTransition(true)
        })
        
    }
    
}
