import UIKit

class MenuHolderViewController: UIViewController {
    
    @IBOutlet weak var backgroundVisualEffectView: UIVisualEffectView!
    @IBOutlet weak var contentView: UIView!
    
    enum RootScreen {
        case gameOverMenu
        case initialMenu
        case pauseMenu
    }
    
    var rootScreen = RootScreen.initialMenu
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let navigationController = segue.destination as? UINavigationController {
            var storyboardId: String!
            switch rootScreen {
            case .gameOverMenu:
                storyboardId = "GameOverMenuViewController"
            case .initialMenu:
                storyboardId = "InitialMenuViewController"
            case .pauseMenu:
                storyboardId = "PauseMenuViewController"
            }
            navigationController.viewControllers = [UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: storyboardId)]
        }
    }
    
}
