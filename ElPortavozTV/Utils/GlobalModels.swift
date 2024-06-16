import UIKit
import AVKit
import Nuke

var dateformater: DateFormatter {
    let df = DateFormatter()
    df.dateFormat = "MM/dd/yyyy"
    return df
}
enum ItemType: String, Codable, Hashable {
    case series = "Series"
    case movie = "Movie"
    case season = "Season"
    case episode = "Episode"
    case liveTV = "LiveTV"
    case shorts = "Shorts"
    case miniSeries = "Mini Series"
}
protocol DisplayableItem: Identifiable, Codable {
    var id: String {get}
    var title: String {get}
    var description: String {get}
    var imageUrl: String {get}
    var backgroundImageURL: String {get}
    var type: ItemType {get}
}
protocol PlayerItem: DisplayableItem {
    var item: AVPlayerItem? { get }
    var duration: Int { get }
    var subtitleURL: URL? { get }
    var metadata: [AVMetadataItem] { get }
}
extension PlayerItem {
    var autoPlayNextDuration: Int {
        10
    }
    func makeMetadataItem(_ identifier: AVMetadataIdentifier, value: Any) -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        item.identifier = identifier
        item.value = value as? NSCopying & NSObjectProtocol
        item.extendedLanguageTag = "und"
        return item.copy() as! AVMetadataItem
    }
}
protocol ListCollectionSection {
    associatedtype ID: Comparable & Equatable
    var id: ID {get}
    var title: String {get}
    var items: [any DisplayableItem] {get}
    //var type: ItemType {get}
}
protocol SectionedCell {
    var reuseId: String { get }
    var delegate: ItemSelctionDelegate? { get set }
    func load(section: any ListCollectionSection)
}

protocol ItemSelctionDelegate {
    func itemSelected(item: any DisplayableItem, at indexPath: IndexPath, in section: any ListCollectionSection)
    func didFocusItem(indexPath: IndexPath, in section: any ListCollectionSection)
}


extension Feed.Movie: PlayerItem {
    
    var item: AVPlayerItem? {
        guard let videoUrl, let url = URL(string: videoUrl) else {
            return nil
        }
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        playerItem.externalMetadata = metadata
        return playerItem
    }
    var metadata: [AVMetadataItem] {
        var metadata = [AVMetadataItem]()
        let titleItem = makeMetadataItem(.commonIdentifierTitle, value: title)
        metadata.append(titleItem)
        let descItem = makeMetadataItem(.commonIdentifierDescription, value: longDescription)
        metadata.append(descItem)
        return metadata
    }
}

extension Feed.Series: PlayerItem {
    var item: AVPlayerItem? {
        guard type == .miniSeries else {
            return nil
        }
        guard let videoUrl, let url = URL(string: videoUrl) else {
            return nil
        }
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        playerItem.externalMetadata = metadata
        return playerItem
    }
    var metadata: [AVMetadataItem] {
        var metadata = [AVMetadataItem]()
        let titleItem = makeMetadataItem(.commonIdentifierTitle, value: title)
        metadata.append(titleItem)
        let descItem = makeMetadataItem(.commonIdentifierDescription, value: longDescription)
        metadata.append(descItem)
        return metadata
    }

}
extension Feed.Episode: PlayerItem {
    var item: AVPlayerItem? {
        guard let videoURL, let url = URL(string: videoURL) else {
            return nil
        }
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        playerItem.externalMetadata = metadata
        return playerItem
    }
    var metadata: [AVMetadataItem] {
        var metadata = [AVMetadataItem]()
        let titleItem = makeMetadataItem(.commonIdentifierTitle, value: title)
        metadata.append(titleItem)
        let descItem = makeMetadataItem(.commonIdentifierDescription, value: longDescription)
        metadata.append(descItem)
        return metadata
    }
}
