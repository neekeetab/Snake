import UIKit

class BlockingActivityIndicatorView: UIView {
    
    private var ai: UIActivityIndicatorView!
    
    func startAnimating() {
        ai.startAnimating()
    }
    
    func stopAnimating() {
        ai.stopAnimating()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.black.withAlphaComponent(100/255)
        
        ai = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        ai.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        addSubview(ai)
        
        autoresizingMask = [.flexibleWidth, .flexibleHeight,.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        ai.center = self.center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
