import UIKit

class InitialMenuViewController: UIViewController {

    @IBOutlet weak var replayButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        replayButton.isHighlighted = !GameRecorder.previousRecordingExists
        replayButton.isEnabled = GameRecorder.previousRecordingExists
    }
    
    @IBAction func newGame(_ sender: Any) {
        GameController.shared.newGame()
        dismiss(animated: true)
    }
    
    @IBAction func replay(_ sender: Any) {
        dismiss(animated: true)
        GameController.shared.replay()
    }
}
