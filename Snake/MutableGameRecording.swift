import Foundation

class MutableGameRecording: Codable {
    
    var initialState: Field.State
    var updates: [Field.Update]
    var lastState: Field.State
    var isFinished: Bool
    
    init(initialState: Field.State, updates: [Field.Update], lastState: Field.State, isFinished: Bool, isGameOver: Bool) {
        self.initialState = initialState
        self.updates = updates
        self.lastState = lastState
        self.isFinished = isFinished
    }
    
}
