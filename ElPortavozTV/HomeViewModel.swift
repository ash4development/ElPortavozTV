//
//  HomeViewModel.swift
//  ElPortavozTV
//
//

import Foundation
enum Home
{
    struct Section: ListCollectionSection {
        var id: String
        var title: String
        var items: [any DisplayableItem]
    }
    
}

class HomeViewModel {
    let feedUrl = "https://api.npoint.io/09cdfa28153b01a1e585"
    func getVideos(completion: @escaping ([Home.Section]?, String?) -> Void) {
        let request = URLRequest(url: URL(string: feedUrl)!)
        NetworkManager.shared.hitApi(urlRequest: request) { (response: Response<Feed.Response>) in
            guard response.isSuccess, let value = response.value else {
                let error = NetworkManager.shared.errorString(from: response) ?? "Unable to load app!"
                completion(nil, error)
                return
            }
            self.formatFeed(feedData: value, completion: { feed in
                completion(feed, nil)
            })
        }
    }
    
    func formatFeed(feedData: Feed.Response, completion: @escaping ([Home.Section]) -> Void) {
        DispatchQueue.global().async {
            var sections: [Home.Section] = []
            for category in feedData.categories {
                let playlistName = category.playlistName
                let playlists = feedData.playlists.filter({$0.name == playlistName})
                guard let playlist = playlists.first else {
                    continue
                }
                let sectioName = category.name
                var items: [any DisplayableItem] = []
                let itemIds = playlist.itemIds
                items += feedData.movies?.filter({itemIds.contains($0.id)}) ?? []
                items += feedData.shortFormVideos?.filter({itemIds.contains($0.id)}).map { short in
                    var short = short
                    short.type = .shorts
                    return short
                } ?? []
                items += feedData.series?.filter({itemIds.contains($0.id)}).map({ series in
                    var series = series
                    series.type = .series
                    return series
                }) ?? []
                items += feedData.tvSpecials?.filter({itemIds.contains($0.id)}).map({ tvSpecial in
                    var tvSpecial = tvSpecial
                    tvSpecial.type = .miniSeries
                    return tvSpecial
                }) ?? []
                if !items.isEmpty {
                    let section = Home.Section(id: playlistName, title: sectioName, items: items)
                    sections += [section]
                }
            }
            
            DispatchQueue.main.async {
                completion(sections)
            }
        }
        
    }
}
