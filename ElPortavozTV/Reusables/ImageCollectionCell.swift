import UIKit
import Nuke
class ImageCollectionCell: UICollectionViewCell {
    var task: ImageTask?
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel! {
        didSet {
            titleLabel.text = nil
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        task?.cancel()
        titleLabel.text = nil
        self.imageView.image = nil
    }
    func showImage(item: any DisplayableItem, keepTitle: Bool = false) {
        self.imageView.image = nil
        guard let url = URL(string: item.imageUrl) else {
            self.titleLabel.text = item.title
            return
        }
        self.titleLabel.text = keepTitle ? item.title : nil
        let request = ImageRequest(url: url)
        if let response = ImageCache.shared[request] { // Check If image already exist in cache...
            self.imageView.image = response.image
            return
        }
        task?.cancel()
        task = ImagePipeline.shared.loadData(with: url, completion: { result in
            switch result {
            case .success(let success):
                let image = UIImage(data: success.data)
                DispatchQueue.main.async {[weak self] in
                    guard let self else{
                        return
                    }
                    self.imageView.alpha = 0
                    self.imageView.image = image
                    UIView.animate(withDuration: 0.3) {
                        self.imageView.alpha = 1
                    }
                }
            case .failure:
                self.titleLabel.text = item.title
            }
        })
    }
}
