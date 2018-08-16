import Foundation

extension Set where Element: Codable {
    init(_ q: Queue<Element>) {
        self.init()
        var qCopy = q
        while (!qCopy.isEmpty) {
            if let el = qCopy.dequeue() {
                insert(el)
            }
        }
    }
}
