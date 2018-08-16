import Foundation

// copied from here: https://github.com/raywenderlich/swift-algorithm-club/blob/master/Queue/Queue-Optimized.swift
public struct Queue<T: Codable>: Codable {
    fileprivate var array = [T?]()
    fileprivate var head = 0
    
    public var isEmpty: Bool {
        return count == 0
    }
    
    public var count: Int {
        return array.count - head
    }
    
    public mutating func enqueue(_ element: T) {
        array.append(element)
    }
    
    public mutating func dequeue() -> T? {
        guard head < array.count, let element = array[head] else { return nil }
        
        array[head] = nil
        head += 1
        
        let percentage = Double(head)/Double(array.count)
        if array.count > 50 && percentage > 0.25 {
            array.removeFirst(head)
            head = 0
        }
        
        return element
    }
    
    public var front: T? {
        if isEmpty {
            return nil
        } else {
            return array[head]
        }
    }
    
    public var tail: T? {
        if isEmpty {
            return nil
        } else {
            return array.last!
        }
    }
    
    public var tailSecond: T? {
        if array.count < 2 {
            return nil
        } else {
            return array[array.count - 2]
        }
    }
    
    public init(_ array: [T]) {
        for element in array {
            enqueue(element)
        }
    }
    
    public init() { }
    
}
