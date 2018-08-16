import Foundation
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

class GameRecorder {
    
    // MARK: - Public interface
    
    private static let filename = "saving.json"
    
    class var previousRecordingExists: Bool {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let path = dir.appendingPathComponent(filename)
            if FileManager.default.fileExists(atPath: path.path) {
                return true
            }
        }
        return false
    }
    
    class func newRecording(initialState: Field.State, updates: Signal<Field.Update, NoError>) -> GameRecorder {
        return GameRecorder(initialState: initialState, updates: updates)
    }
    
    class func continueRecording(gameRecording: MutableGameRecording, updates: Signal<Field.Update, NoError>) -> GameRecorder {
        return GameRecorder(gameRecording: gameRecording, updates: updates)
    }
    
    // Sends MutableGameRecording on successful disk read then completes
    // nil if there's been no recording saved
    class func lastGameRecording() -> SignalProducer<MutableGameRecording, NoError>? {
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let path = dir.appendingPathComponent(filename)
            if FileManager.default.fileExists(atPath: path.path) {
                return SignalProducer { observer, lifetime in
                    if let encodedData = try? Data(contentsOf: path),
                        let gameRecording = try? JSONDecoder().decode(MutableGameRecording.self, from: encodedData) {
                        observer.send(value: gameRecording)
                        observer.sendCompleted()
                        return
                    }
                    fatalError("oops")
                }
            }
        }
        
        return nil
        
    }
    
    /// Saves recording and sends () on success then completes
    func commit(lastState: Field.State, isGameFinished: Bool) -> SignalProducer<(), NoError> {
        recording.lastState = lastState
        recording.isFinished = isGameFinished
        return SignalProducer { observer, lifetime in
            if let encodedData = try? JSONEncoder().encode(self.recording),
                let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let path = dir.appendingPathComponent("saving.json")
                try? encodedData.write(to: path)
            }
            observer.send(value: ())
            observer.sendCompleted()
        }
    }
    
    // MARK: - Implementation
    
    let recording: MutableGameRecording
    
    init(initialState: Field.State, updates: Signal<Field.Update, NoError>) {
        recording = MutableGameRecording(initialState: initialState, updates: [], lastState: initialState, isFinished: false, isGameOver: false)
        updates
            .take(duringLifetimeOf: self)
            .on(value: { [unowned self] in
                self.recording.updates.append($0)
            })
            .observeCompleted { }
    }
    
    init(gameRecording: MutableGameRecording, updates: Signal<Field.Update, NoError>) {
        recording = gameRecording
        updates
            .take(duringLifetimeOf: self)
            .on(value: { [unowned self] in
                 self.recording.updates.append($0)
            })
            .observeCompleted { }
    }
    
}
