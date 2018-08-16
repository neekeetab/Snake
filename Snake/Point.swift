import Foundation

struct Point: Hashable, Codable {
    let x: Int
    let y: Int
    func normalized(n: Int, m: Int) -> Point {
        return Point(x: ((x % m) + m) % m, y: ((y % n) + n) % n)
    }
    static func random() -> Point {
        return Point(x: Int(arc4random()), y: Int(arc4random()))
    }
}

func +(lhs: Point, rhs: Point) -> Point {
    return Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}
