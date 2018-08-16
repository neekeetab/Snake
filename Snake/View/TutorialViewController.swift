import UIKit

class TutorialCell2: UICollectionViewCell {
    
    @IBOutlet weak var fieldView: FieldView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        fieldView[Point(x: 2, y: 1)]?.backgroundColor = Palette.canary
    }
    
}

class TutorialCell3: UICollectionViewCell {
    
    @IBOutlet weak var fieldView: FieldView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        fieldView[Point(x: 1, y: 1)]?.backgroundColor = Palette.mediumAquamarine
        fieldView[Point(x: 2, y: 1)]?.backgroundColor = Palette.mediumAquamarine
        fieldView[Point(x: 3, y: 1)]?.backgroundColor = Palette.mediumAquamarine
        
    }
    
}


class TutorialViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
    
    @IBAction func gotIt(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = collectionView.frame.size
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing = 0
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing = 0
    }
    
}

extension TutorialViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.item {
        case 0:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "cell1", for: indexPath)
        case 1:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "cell2", for: indexPath)
        case 2:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "cell3", for: indexPath)
        case _:
            fatalError("internal inconsistency")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
    }
    
}
