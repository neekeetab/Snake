import UIKit
import ReactiveCocoa
import ReactiveSwift
import enum Result.NoError
import AudioToolbox.AudioServices

fileprivate let emptyColor = Palette.yankeesBlue
fileprivate let snakeColor = UIColor.white
fileprivate let feedColor = Palette.canary
fileprivate let obstacleColor = Palette.mediumAquamarine

class ViewController: UIViewController {
    
    @IBOutlet weak var fieldView: FieldView!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var numberLabel: UILabel!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberLabel?.alpha = 0
        
        // handle taps
        tapGestureRecognizer.reactive.stateChanged
            .filter { $0.state == .recognized }
            .on(value: { _ in
                GameController.shared.pause()
            })
            .observeCompleted { }
        
        // handle game state changes
        GameController.shared.state.producer
            .observe(on: QueueScheduler.main)
            // vibrate on gameover
            .on(value: {
                if $0 == .gameOver {
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                }
            })
            // don't show any new screens until loading is done
            .combineLatest(with: GameController.shared.isLoading)
            .filter { $0.1 == false }
            .map { $0.0 }
            // show appropriate menu
            .on(value: {
                switch $0 {
                case .empty, .gameOver, .paused, .ready:
                    if self.presentedViewController == nil {
                        self.performSegue(withIdentifier: "menuRootViewController", sender: nil)
                    }
                case _: break
                }
            })
            .start()
        
        // show activity indicator on loading
        view.reactive.isBlockedWithActivityIndicator <~ GameController.shared.isLoading
        
        // handle countodown
        numberLabel.reactive.text <~ GameController.shared.secondsBeforeStart
            .signal
            .map { $0 != 0 ? "\($0)" : "GO!" }
            .observe(on: QueueScheduler.main)
            .on(value: { _ in
                self.numberLabel.transform = .identity
                self.numberLabel.alpha = 1
                UIView.animate(withDuration: 0.4) {
                    self.numberLabel.transform = CGAffineTransform.identity.scaledBy(x: 3, y: 3)
                    self.numberLabel.alpha = 0
                }
            })
        
        // handle game field updates
        GameController.shared.field
            .producer
            .observe(on: QueueScheduler.main)
            .on(value: { field in
                
                _ = self.fieldView.pointViews.flatMap { $0 }
                    .map { $0.backgroundColor = emptyColor }
                
                _ = field.initialState.obstacles.map { self.fieldView[$0]?.backgroundColor = obstacleColor }
                
                _ = Set(field.initialState.snakeQueue).map { self.fieldView[$0]?.backgroundColor = snakeColor }
                
                self.fieldView[field.initialState.feed]?.backgroundColor = feedColor
                
            })
            .flatMap(.latest) { $0.updates }
            .observe(on: QueueScheduler.main)
            .on(value: { update in

                func processUpdate(_ update: Field.Update) {
                    switch update {
                    case .empty(let point):
                        self.fieldView[point]?.backgroundColor = emptyColor
                    case .feed(let point):
                        self.fieldView[point]?.backgroundColor = feedColor
                    case .snake(let point):
                        self.fieldView[point]?.backgroundColor = snakeColor
                    case .multiple(let updates):
                        _ = updates.map { processUpdate($0) }
                    }
                }

                processUpdate(update)

            })
            .start()
        
        // make small vibrations on rotation changes when game is in progress
        GameController.shared.field.producer
            .flatMap(.latest) { field -> Signal<(), NoError> in
                
                if field.isPlayingFromRecording {
                    return Signal.empty
                }
                
                return MotionManager.shared.rotation
                    .combineLatest(with: GameController.shared.state.signal)
                    .filter { $0.1 == .inProgress || $0.1 == .countdown }
                    .map { $0.0 }
                    .skipRepeats()
                    .on(value: { _ in
                        let peek = SystemSoundID(1519)
                        AudioServicesPlaySystemSound(peek)
                    })
                    .map { _ in () }
                
            }
            .start()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let menuHolderViewController = segue.destination as? MenuHolderViewController {
            switch GameController.shared.state.value {
            case .gameOver:
                menuHolderViewController.rootScreen = .gameOverMenu
            case .paused:
                menuHolderViewController.rootScreen = .pauseMenu
            case .ready:
                menuHolderViewController.rootScreen = .initialMenu
                case _: break
            }
            menuHolderViewController.transitioningDelegate = self
        }
    }

}

extension ViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MenuHolderPresentTransition()
        
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MenuHolderDismissTransition()
    }
}


