import UIKit

@IBDesignable
class FieldView: UIView {
    
    // MARK: - Public interface
    
    subscript(point: Point) -> UIView? {
        if point.x < m && point.x >= 0 && point.y < n && point.y >= 0 {
            return pointViews[point.x][point.y]
        }
        return nil
    }
    
    @IBInspectable
    public var n: Int = 0 {
        didSet {
            _ = pointViews.flatMap { $0 }.map { $0.removeFromSuperview() }
            let dummyView = UIView()
            pointViews = [[UIView]](repeating: [UIView](repeating: dummyView, count: n), count: m)
            for i in 0 ..< m {
                for j in 0 ..< n {
                    let pointView = UIView()
                    pointView.backgroundColor = Palette.yankeesBlue
                    addSubview(pointView)
                    pointViews[i][j] = pointView
                }
            }
        }
    }
    
    @IBInspectable
    public var m: Int = 0 {
        didSet {
            _ = pointViews.flatMap { $0 }.map { $0.removeFromSuperview() }
            let dummyView = UIView()
            pointViews = [[UIView]](repeating: [UIView](repeating: dummyView, count: n), count: m)
            for i in 0 ..< m {
                for j in 0 ..< n {
                    let pointView = UIView()
                    pointView.backgroundColor = Palette.yankeesBlue
                    addSubview(pointView)
                    pointViews[i][j] = pointView
                }
            }

        }
    }
    
    private(set) var pointViews = [[UIView]]()
    
    // MARK: -
    
    private let padding: CGFloat = 3
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutPoints()
    }
    
    private func layoutPoints() {
        
        let xSize = (bounds.size.width - padding * CGFloat(m - 1)) / CGFloat(m)
        let ySize = (bounds.size.height - padding * CGFloat(n - 1)) / CGFloat(n)
        let pointSize = min(xSize, ySize)
        
        let fieldWidth = pointSize * CGFloat(m) + padding * CGFloat(m - 1)
        let fieldHeight = pointSize * CGFloat(n) + padding * CGFloat(n - 1)
        
        let xOffset = (bounds.size.width - fieldWidth) / 2
        let yOffset = (bounds.size.height - fieldHeight) / 2
        
        for i in 0 ..< n {
            for j in 0 ..< m {
                let x = CGFloat(j) * (pointSize + padding)
                let y = CGFloat(i) * (pointSize + padding)
                let rect = CGRect(x: xOffset + x, y: yOffset + y, width: pointSize, height: pointSize)
                pointViews[j][i].frame = rect
            }
        }
        
    }
    
}
