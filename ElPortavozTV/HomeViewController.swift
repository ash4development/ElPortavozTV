//
//  HomeViewController.swift
//  ElPortavozTV
//

import UIKit
import AVKit
import Nuke

class HomeViewController: BaseViewController {
    
    @IBOutlet var sectionedList: SectionedList! {
        didSet {
            sectionedList.delegate = self
        }
    }
    @IBOutlet var backgroundImageView: UIImageView! {
        didSet {
            backgroundImageView.alpha = 0.5
        }
    }
    @IBOutlet var titleLabel: UILabel! {
        didSet {
            titleLabel.text = ""
        }
    }
    @IBOutlet var dateLabel: UILabel! {
        didSet {
            dateLabel.text = ""
        }
    }
    @IBOutlet var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.text = ""
        }
    }
    var task: ImageTask?
    let avplayer = AVPlayer()
    let avplayerViewController = AVPlayerViewController()
    let viewModel = HomeViewModel()
    var sections: [Home.Section] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchVideos()
    }
    func fetchVideos() {
        showLoading()
        viewModel.getVideos { feedSections, errorMessage in
            self.hideLoading()
            guard let feedSections else {
                self.showAlert(title: "", message: errorMessage ?? "Unable to fetch videos", actions: UIAlertAction(title: "OK", style: .default))
                return
            }
            self.sections = feedSections
            self.sectionedList.display(sections: feedSections)
        }
    }
}
extension HomeViewController: ItemSelctionDelegate {
    func itemSelected(item: any DisplayableItem, at indexPath: IndexPath, in section: any ListCollectionSection) {
        guard let playableItem = item as? (any PlayerItem) else {
            showAlert(title: "", message: "The video can not be played.", actions: UIAlertAction(title: "OK", style: .default))
            return
        }
        guard let item = playableItem.item else {
            showAlert(title: "", message: "The video can not be played.", actions: UIAlertAction(title: "OK", style: .default))
            return
        }
        avplayer.replaceCurrentItem(with: item)
        avplayerViewController.player = avplayer
        present(avplayerViewController, animated: true)
        avplayer.play()
    }
    
    func didFocusItem(indexPath: IndexPath, in section: any ListCollectionSection) {
        guard indexPath.row < section.items.count else {
            return
        }
        let item = section.items[indexPath.row]
        titleLabel.text = item.title
        descriptionLabel.text = item.description
        task?.cancel()
        if let url = URL(string: item.imageUrl) {
            showBGImage(url: url)
        }
    }
    private func showBGImage(url: URL) {
        task?.cancel()
        let request = ImageRequest(url: url)
        if let response = ImageCache.shared[request] { // Check If image already exist in cache...
            self.backgroundImageView.image = response.image
            return
        }
        task = ImagePipeline.shared.loadData(with: url, completion: { result in
            switch result {
            case .success(let success):
                let image = UIImage(data: success.data)
                DispatchQueue.main.async {[weak self] in
                    guard let self else{
                        return
                    }
                    self.backgroundImageView.alpha = 0
                    self.backgroundImageView.image = image
                    UIView.animate(withDuration: 0.3) {
                        self.backgroundImageView.alpha = 0.5
                    }
                }
            case .failure(let error):
                print(error)
            }
        })
    }
}
