import UIKit

class CollectionViewSelectionDelegate: NSObject, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var didSelectItem: ((IndexPath) -> Void)?
    var didFocusItem: ((IndexPath?) -> Void)?
    var horizontalItemSpacing: CGFloat = 40
    var verticalItemSpacing: CGFloat = 20
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectItem?(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        var spacing: CGFloat = verticalItemSpacing
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout, flowLayout.scrollDirection == .horizontal
        {
            spacing = self.horizontalItemSpacing
        }
        return spacing
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        var spacing: CGFloat = verticalItemSpacing
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout, flowLayout.scrollDirection == .horizontal
        {
            spacing = self.horizontalItemSpacing
        }
        return spacing
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var itemSpacing: CGFloat = self.verticalItemSpacing
        let insets = collectionView.contentInset.left + collectionView.contentInset.right
        var numberOfCells: CGFloat = 2
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout, flowLayout.scrollDirection == .horizontal
        {

            numberOfCells = 2.03
        }
        
        if UIDevice.isTV
        {
//            itemSpacing = 10
            if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout, flowLayout.scrollDirection == .horizontal
            {
                numberOfCells = 3.5
                itemSpacing = self.horizontalItemSpacing
            }
            else
            {
                numberOfCells = 3
            }
        }
        else if UIDevice.isPad
        {
            numberOfCells = 4
        }
        let width = collectionView.frame.width - ((itemSpacing * numberOfCells - 1 ) + insets)
        let cellWidth = floor(width/numberOfCells)
        let size = CGSize(width: cellWidth, height: cellWidth/2)
        return size
    }
}

#if os(tvOS)
extension CollectionViewSelectionDelegate
{
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {

        if let indexPath = context.previouslyFocusedIndexPath,
           let cell = collectionView.cellForItem(at: indexPath) {
            UIView.animate(withDuration: 0.4) {
                cell.transform = .identity
                cell.layer.borderWidth = 0
            }
        }

        if let indexPath = context.nextFocusedIndexPath,
           let cell = collectionView.cellForItem(at: indexPath) {
            collectionView.clipsToBounds = false
            UIView.animate(withDuration: 0.4) {
//                if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout, flowLayout.scrollDirection == .vertical
//                {
//                    cell.transform3D = CATransform3DMakeScale(1.1, 1.1, 1.5)
//                    cell.layer.borderColor = UIColor.white.cgColor
//                    cell.layer.borderWidth = 5
//                }
//                else
//                {
                    cell.transform3D = CATransform3DMakeScale(1.18, 1.18, 1.5)
                    cell.layer.borderColor = UIColor.white.cgColor
                    cell.layer.borderWidth = 5
//                }
            }
            collectionView.bringSubviewToFront(cell)
        }
        didFocusItem?(context.nextFocusedIndexPath)
    }
}
#endif
