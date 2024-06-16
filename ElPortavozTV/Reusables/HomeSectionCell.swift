import UIKit
class HomeSectionCell: UITableViewCell, SectionedCell {
    var reuseId: String = "HomeSectionCell"
    @IBOutlet var titleLable: UILabel! {
        didSet {
            titleLable.text = nil
        }
    }
    @IBOutlet var displaybleCollectionView: DisplayableCollectionView! {
        didSet {
            displaybleCollectionView.collectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        }
    }
    @IBOutlet var countLabel: UILabel! {
        didSet {
            countLabel.text = nil
        }
    }
    private var section: (any ListCollectionSection)?
    var delegate: ItemSelctionDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        countLabel.text = nil
    }
    func load(section: any ListCollectionSection) {
        self.section = section
        titleLable.text = section.title
        displaybleCollectionView.dataSource = section.items
        displaybleCollectionView.didSelect = {[weak self] indexPath in
            self?.handleSelection(at: indexPath)
        }
        displaybleCollectionView.didFocusItem = {[weak self, section] indexPath in
            guard let indexPath else {
                self?.countLabel.text = nil
                return
            }
            self?.countLabel.text = "\(indexPath.row + 1) of \(section.items.count)"
            self?.delegate?.didFocusItem(indexPath: indexPath, in: section)
        }
    }
    func handleSelection(at indexPath: IndexPath) {
        guard let section else {
            return
        }
        let item = section.items[indexPath.row]
        delegate?.itemSelected(item: item, at: indexPath, in: section)
    }
}

