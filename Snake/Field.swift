import Foundation
import ReactiveSwift
import enum Result.NoError

class Field {
    
    // MARK: - Public interface
    
    static let n = 33
    static let m = 18
    static let numberOfObstacles = 4
    
    static let empty = Field(initialState: State(obstacles: Set(), snakeQueue: Queue(), feed: Point(x: -1, y: -1)), clock: Signal<(), NoError>.empty, motionManager: MotionManager.shared)
    
    enum Update: Codable {
        
        case empty(Point)
        case snake(Point)
        case feed(Point)
        case multiple([Update])
        
        enum CodingKeys: String, CodingKey {
            case empty
            case snake
            case feed
            case multiple
        }
        
        init(from decoder: Decoder) throws {
            
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            if let point = try? values.decode(Point.self, forKey: .empty) {
                self = .empty(point)
                return
            }
            
            if let point = try? values.decode(Point.self, forKey: .snake) {
                self = .snake(point)
                return
            }
            
            if let point = try? values.decode(Point.self, forKey: .feed) {
                self = .feed(point)
                return
            }
            
            if let updates = try? values.decode([Update].self, forKey: .multiple) {
                self = .multiple(updates)
                return
            }
            
            self = .empty(Point(x: 0, y: 0))
            
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .empty(let point):
                try container.encode(point, forKey: .empty)
            case .snake(let point):
                try container.encode(point, forKey: .snake)
            case .feed(let point):
                try container.encode(point, forKey: .feed)
            case .multiple(let points):
                try container.encode(points, forKey: .multiple)
            }
        }
    }
    
    struct State: Codable {
        let obstacles: Set<Point>
        let snakeQueue: Queue<Point>
        let feed: Point
    }
    
    let isPlayingFromRecording: Bool
    let initialState: State
    let updates: Signal<Update, NoError>
    let isGameOver: MutableProperty<Bool>
    
    var currentState: State {
        return State(obstacles: obstacles, snakeQueue: snakeQueue, feed: feed)
    }
    
    // MARK: - Implementation
    
    private var obstacles: Set<Point>
    private var snakeQueue: Queue<Point>
    private var snakeSet: Set<Point> // to efficiently detect collisions
    private var feed: Point
    private let updatesObserver: Signal<Update, NoError>.Observer
    
    private static func generateObstacles(snakeSet: Set<Point> = []) -> Set<Point> {
        
        let obstacleSample1 = [(0, 0), (0, 1), (1, 2), (1, 2)]
        let obstacleSample2 = [(0, 1), (1, 1), (2, 1), (2, 0)]
        let obstacleSample3 = [(0, 1), (1, 1), (1, 0)]
        let obstacleSample4 = [(0, 0), (1, 1)]
        let obstacleSample5 = [(0, 0), (0, 1)]
        
        let samples = [obstacleSample1, obstacleSample2, obstacleSample3, obstacleSample4, obstacleSample5].map { $0.map { tuple in Point(x: tuple.0, y: tuple.1) } }
            .map { Set($0) }
        
        let generatedObstacles: [Set<Point>] = Array(0 ..< numberOfObstacles).map { _ in
            
            var obstacle: Set<Point>!

            func generateObstacle() -> Set<Point> {
                let shiftPoint = Point.random().normalized(n: n, m: m)
                let obstacle = samples[Int(arc4random()) % samples.count]
                let shiftedObstacle = Set(obstacle.map { ($0 + shiftPoint).normalized(n: n, m: m) })
                return shiftedObstacle
            }

            func intersectsWithSnake(_ t_obstacle: Set<Point>) -> Bool {
                obstacle = t_obstacle
                return !obstacle.intersection(snakeSet).isEmpty
            }

            while intersectsWithSnake(generateObstacle()) { }

            return obstacle
            
        }
        
        return Set(generatedObstacles.flatMap { $0 })
        
    }
    
    private static func generateFeed(snakeSet: Set<Point> = [], obstacles: Set<Point> = []) -> Point {
        
        var point: Point!

        func intersectsWithAnything(_ t_point: Point) -> Bool {
            point = t_point
            return obstacles.contains(point) || snakeSet.contains(point)
        }

        while intersectsWithAnything(Point.random().normalized(n: n, m: m)) { }

        return point
        
    }
    
    private static func snakeInitialPosition() -> Queue<Point> {
        return Queue([(m / 2 - 2, n / 2), (m / 2 - 1, n / 2), (m / 2, n / 2), (m / 2 + 1, n / 2)].map { Point(x: $0.0, y: $0.1) })
    }
    
    private static func generateInitialState() -> State {
        
        let snakeQueue = snakeInitialPosition()
        let obstacles = generateObstacles(snakeSet: Set(snakeQueue))
        let feed = generateFeed(snakeSet: Set(snakeQueue), obstacles: obstacles)
        
        return State(obstacles: obstacles, snakeQueue: snakeQueue, feed: feed)
        
    }
    
    private func processTick(rotation: MotionManager.Rotation) {
        
        func shiftPoint(for rotation: MotionManager.Rotation) -> Point {
            switch rotation {
            case .back:
                return Point(x: 0, y: 1)
            case .forth:
                return Point(x: 0, y: -1)
            case .left:
                return Point(x: -1, y: 0)
            case .right:
                return Point(x: 1, y: 0)
            }
        }
        
        var bundle = [Update]()
        
        // move head one step futher
        var newTail = (snakeQueue.tail! + shiftPoint(for: rotation)).normalized(n: Field.n, m: Field.m)
        if newTail == snakeQueue.tailSecond! {
            newTail = (snakeQueue.tail! + shiftPoint(for: rotation.opposite)).normalized(n: Field.n, m: Field.m)
        }
        
        // check crossing itself
        if snakeSet.contains(newTail) {
            defer {
                isGameOver.value = true
            }
        }
        
        snakeSet.insert(newTail)
        snakeQueue.enqueue(newTail)
        bundle.append(.snake(newTail))
        
        // check crossing feed
        if newTail == feed {
            feed = Field.generateFeed(snakeSet: snakeSet, obstacles: obstacles)
            bundle.append(.feed(feed))
        } else {
            // move tail one step further
            let oldHead = snakeQueue.dequeue()!
            snakeSet.remove(oldHead)
            bundle.append(.empty(oldHead))
        }
        
        // check crossing obstacles
        if obstacles.contains(newTail) {
            defer {
                isGameOver.value = true
            }
        }
        
        updatesObserver.send(value: .multiple(bundle))
        
    }
    
    init(initialState: State, clock: Signal<(), NoError>, motionManager: MotionManager) {
        
        isPlayingFromRecording = false
        self.initialState = initialState
        (updates, updatesObserver) = Signal.pipe()
        isGameOver = MutableProperty(false)
        obstacles = initialState.obstacles
        snakeQueue = initialState.snakeQueue
        snakeSet = Set(initialState.snakeQueue)
        feed = initialState.feed
        
        motionManager.rotation.sample(on: clock)
            .take(until: isGameOver.signal.filter { $0 }.map { _ in () })
            .take(duringLifetimeOf: self)
            .on(value: { [unowned self] in
                self.processTick(rotation: $0)
            })
            .observeCompleted { }
        
    }
    
    init(clock: Signal<(), NoError>, motionManager: MotionManager) {
        
        isPlayingFromRecording = false
        initialState = Field.generateInitialState()
        (updates, updatesObserver) = Signal.pipe()
        isGameOver = MutableProperty(false)
        obstacles = initialState.obstacles
        snakeQueue = initialState.snakeQueue
        snakeSet = Set(initialState.snakeQueue)
        feed = initialState.feed
        
        motionManager.rotation.sample(on: clock)
            .take(until: isGameOver.signal.filter { $0 }.map { _ in () })
            .take(duringLifetimeOf: self)
            .on(value: { [unowned self] in
               self.processTick(rotation: $0)
            })
            .observeCompleted { }
        
    }
    
    init(clock: Signal<(), NoError>, recording: MutableGameRecording) {
        
        isPlayingFromRecording = true
        initialState = recording.initialState
        (updates, updatesObserver) = Signal.pipe()
        isGameOver = MutableProperty(false)
        obstacles = initialState.obstacles
        snakeQueue = initialState.snakeQueue
        snakeSet = Set(initialState.snakeQueue)
        feed = initialState.feed
        
        guard recording.updates.count != 0 else {
            isGameOver <~ clock.take(first: 1).map { true }
            return
        }
        
        SignalProducer<Update, NoError>(recording.updates)
            .zip(with: clock)
            .map { $0.0 }
            .take(duringLifetimeOf: self)
            .on(value: { [unowned self] in
                self.updatesObserver.send(value: $0)
            })
            .on(completed: { [weak self] in
                self?.isGameOver.value = true
            })
            .start()
        
    }
    
}
