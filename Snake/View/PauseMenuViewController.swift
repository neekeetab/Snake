import UIKit
import ReactiveCocoa
import ReactiveSwift

class PauseMenuViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
    
    @IBAction func resume(_ sender: Any) {
        dismiss(animated: true)
        GameController.shared.resume()
    }
    
    @IBAction func end(_ sender: Any) {
        
        view.reactive.isBlockedWithActivityIndicator <~ SignalProducer([true])
        
        view.reactive.isBlockedWithActivityIndicator <~ GameController.shared.end()
            .map { _ in false }
            .observe(on: QueueScheduler.main)
            .on(value: { [unowned self] _ in
                self.performSegue(withIdentifier: "showInitialMenu", sender: nil)
            })
        
    }
    
    
    
}
