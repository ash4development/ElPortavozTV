//
//  SeriesEpisodeCell.swift
//
//

import UIKit
import Nuke

class SeriesEpisodeCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var stackSpacing: NSLayoutConstraint! {
        didSet {
            stackSpacing.constant = 0
        }
    }
    @IBOutlet var stackWidth: NSLayoutConstraint! {
        didSet {
            stackWidth.constant = 0
        }
    }
    
    @IBOutlet var textStackView: UIStackView!
    var task: ImageTask?
    var item: (any DisplayableItem)?
    override func prepareForReuse() {
        super.prepareForReuse()
        task?.cancel()
        titleLabel.text = nil
        self.imageView.image = nil
    }
    func show(item: any DisplayableItem) {
        self.item = item
        titleLabel.text = item.title
        descriptionLabel.text = item.description
        if let url = URL(string: item.imageUrl) {
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
                    break
                }
            })
        }
    }
    func expand(_ expand: Bool) {
        if expand {
            stackWidth.constant = 550
            stackSpacing.constant = 40
            textStackView.isHidden = false
        } else {
            stackWidth.constant = 0
            stackSpacing.constant = 0
            textStackView.isHidden = true
        }
        UIView.performWithoutAnimation {
            invalidateIntrinsicContentSize()
        }
    }
}
