import Foundation
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

class GameController {
    
    // MARK: - Public interface
    
    static let shared = GameController()
    
    let field: MutableProperty<Field>
    let secondsBeforeStart: MutableProperty<Int>
    let isLoading: MutableProperty<Bool>
    let state: MutableProperty<State>
    
    enum State {
        case empty
        case initializing
        case ready
        case countdown
        case inProgress
        case paused
        case gameOver
    }
    
    func newGame() {
        
        field.value = Field(clock: clock.signal, motionManager: MotionManager.shared)
        gameRecorder = GameRecorder.newRecording(initialState: field.value.initialState, updates: field.value.updates)

        resume()

    }

    func pause() {

        if state.value == .inProgress || state.value == .countdown {
            // this will stop the clock
            state.value = .paused
        }

    }

    func resume() {

        state.value = .countdown
        
        secondsBeforeStart <~ SignalProducer.timer(interval: .milliseconds(500), on: QueueScheduler.main)
            .map { _ in return 1 }
            .scan(4, -)
            .take(first: 4)
            .take(until: state.producer.filter { $0 == .paused }.map { _ in () })
            .on(value: {
                if $0 == 0 {
                    self.state.value = .inProgress
                }
            })

        clock <~ state.signal.filter { $0 == .inProgress }.take(first: 1)
            .take(until: state.signal.filter { $0 != .countdown && $0 != .inProgress }.map { _ in () })
            .flatMap(.latest) { _ in
                SignalProducer.timer(interval: .milliseconds(100), on: QueueScheduler.main)
                    .take(until: self.state.signal.filter { $0 != .inProgress }.map { _ in () })
                    .map { _ in () }
            }
        
        let isRecording = field.value.isPlayingFromRecording
        
        state <~ field.value.isGameOver.signal
            .filter { $0 }
            .map { _ in isRecording ? .empty : .gameOver }
            .take(until: state.signal.filter { $0 != .inProgress && $0 != .countdown }.map { _ in () })
            .take(duringLifetimeOf: field.value)
            .on(value: { _ in
                // commit recording if needed
                if let unwrappedGameRecorder = self.gameRecorder {
                    self.isLoading.value = true
                    self.isLoading <~ unwrappedGameRecorder.commit(lastState: self.field.value.currentState, isGameFinished: true).map { false }
                }
            })

    }

    // sends () on success and completes
    @discardableResult
    func end() -> SignalProducer<(), NoError> {

        self.state.value = .ready
        
        if let gameRecorderUnwrapped = self.gameRecorder {
            return gameRecorderUnwrapped.commit(lastState: field.value.currentState, isGameFinished: true)
        }
        
        return SignalProducer(value: ())
        
    }

    func replay() {

        isLoading.value = true
        isLoading <~ (GameRecorder.lastGameRecording() ?? SignalProducer.empty)
            .on(value: { gameRecording in
                self.field.value = Field(clock: self.clock.signal, recording: gameRecording)
                self.gameRecorder = nil
                self.resume()
            })
            .map { _ in false }

    }
    
    func saveIfNeeded() {
        gameRecorder?.commit(lastState: field.value.currentState, isGameFinished: state.value == .gameOver).start()
    }
    
    // MARK: - 
    
    private let clock = MutableProperty<()>(())
    private var gameRecorder: GameRecorder? = nil
    
    init() {
        
        secondsBeforeStart = MutableProperty(0)
        isLoading = MutableProperty(false)
        field = MutableProperty(Field.empty)
        state = MutableProperty(.initializing)
        if let lastGameRecording = GameRecorder.lastGameRecording() {
            isLoading.value = true
            isLoading <~ lastGameRecording
                .on(value: {
                    if $0.isFinished {
                        self.state.value = .empty
                    } else {
                        self.field.value = Field(initialState: $0.lastState, clock: self.clock.signal, motionManager: MotionManager.shared)
                        self.gameRecorder = GameRecorder.continueRecording(gameRecording: $0, updates: self.field.value.updates)
                        self.state.value = .paused
                    }
                })
                .map { _ in false }
        } else {
            state.value = .empty
        }
        
    }
    
}
