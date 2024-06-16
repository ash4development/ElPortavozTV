import UIKit

class DisplayableCollectionView: UIView {
    lazy var collectionViewDelegate = CollectionViewSelectionDelegate()
    var didScroll: ((UIScrollView) -> Void)?
    @IBOutlet var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = collectionViewDelegate
        }
    }
    var dataSource: [any DisplayableItem] = [] {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    var didSelect: ((IndexPath) -> Void)? {
        didSet {
            collectionViewDelegate.didSelectItem = didSelect
        }
    }
    var didFocusItem: ((IndexPath?) -> Void)? {
        didSet {
            collectionViewDelegate.didFocusItem = didFocusItem
        }
    }
    lazy var cellBuilder: ((IndexPath, UICollectionView) -> UICollectionViewCell)? = { (indexPath, collectionView) in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionCell", for: indexPath)
        if let cell = cell as? ImageCollectionCell {
            cell.showImage(item: self.dataSource[indexPath.row])
        }
        return cell
    }
    func reloadData() {
        self.collectionView.reloadData()
    }
}
extension DisplayableCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cellBuilder {
            let cell = cellBuilder(indexPath, collectionView)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionCell", for: indexPath) as! ImageCollectionCell
            cell.showImage(item: dataSource[indexPath.row])
            return cell
        }
    }
}
