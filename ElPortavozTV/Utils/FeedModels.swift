import Foundation

enum Feed {
    struct Response: Codable {
        let language: Language
        let movies: [Movie]?
        let shortFormVideos, series, tvSpecials: [Series]?
        let liveFeeds: [LiveFeed]?
        let categories: [Category]
        let playlists: [Playlist]
    }
    
    // MARK: - Category
    struct Category: Codable {
        let name, playlistName, order: String
    }
    
    enum Language: String, Codable {
        case en = "en"
        case enUS = "en-US"
    }
    
    // MARK: - LiveFeed
    struct LiveFeed: Codable, Identifiable {
        let id, title: String
        let content: LiveFeedContent?
        let thumbnail: String?
        let shortDescription, longDescription: String?
        let tags: [String]?
        let rating: Rating?
        let genres: [String]?
        let brandedThumbnail: String?
    }
    
    // MARK: - LiveFeedContent
    struct LiveFeedContent: Codable {
        let dateAdded: String?
        let videos: [Video]?
        let language: Language?
        let adBreaks: [String]?
        let duration: Int?
    }
    
    // MARK: - Video
    struct Video: Codable, Comparable {
        let url: String
        let quality: Quality
        let videoType: VideoType
        
        static func >(lhs: Video, rhs: Video) -> Bool {
            lhs.quality > rhs.quality
        }
        
        static func < (lhs: Video, rhs: Video) -> Bool {
            lhs.quality < rhs.quality
        }
    }
    
    enum Quality: String, Codable, Comparable {
        
        case fhd = "FHD"
        case hd = "HD"
        case sd = "SD"
        
        var order: Int {
            switch self {
            case .fhd:
                return 3
            case .hd:
                return 2
            case .sd:
                return 1
            }
        }
        
        static func >(lhs: Quality, rhs: Quality) -> Bool {
            lhs.order > rhs.order
        }
        
        static func < (lhs: Feed.Quality, rhs: Feed.Quality) -> Bool {
            lhs.order < rhs.order
        }
    }
    
    enum VideoType: String, Codable {
        case hls = "HLS"
    }
    
    // MARK: - Rating
    struct Rating: Codable {
        let rating: String
        let ratingSource: RatingSource
    }
    
    enum RatingSource: String, Codable {
        case mpaa = "MPAA"
        case usaPR = "USA_PR"
    }
    
    // MARK: - Movie
    struct Movie: Codable, Identifiable {
        let id, title: String
        let content: MovieContent?
        let rating: Rating?
        let genres, tags: [String]?
        let thumbnail: String?
        let thumbnailBoxcover: String?
        let backgroundImage: String?
        let releaseDate, shortDescription, longDescription: String?
        let credits: [Credit]?
        let externalIDS: [ExternalID]?
        
        static var dateFormater = DateFormatter()
        var releaseYear: String? {
            guard let releaseDate else {
                return nil
            }
            let df = Movie.dateFormater
            df.dateFormat = "yyy-MM-dd"
            let date = df.date(from: releaseDate)
            df.dateFormat = "yyyy"
            return df.string(from: date!)
        }
        
        var videoUrl: String? {
            content?.videoUrl
        }
        
        var duration: Int {
            content?.duration ?? 0
        }
        
        var subtitleURL: URL? {
            content?.subtitleURL
        }
    }
    
    // MARK: - MovieContent
    struct MovieContent: Codable {
        let dateAdded: String?
        let videos: [Video]?
        let duration: Int?
        let language: Language?
        let adBreaks: [String]?
        let captions: [Caption]?
        let trickPlayFiles: [TrickPlayFile]?
        
        var videoUrl: String? {
            videos?.max()?.url
        }
        
        var subtitleURL: URL? {
            if let url = captions?.first?.url {
                return URL(string: url)
            }
            return nil
        }
    }
    
    // MARK: - Caption
    struct Caption: Codable {
        let url: String
        let language: Language
        let captionType: String
    }
    
    // MARK: - TrickPlayFile
    struct TrickPlayFile: Codable {
        let url: String
        let quality: Quality
    }
    
    // MARK: - Credit
    struct Credit: Codable {
        let name, role, birthDate: String
    }
    
    // MARK: - ExternalID
    struct ExternalID: Codable {
        let id, idType: String
    }
    
    // MARK: - Playlist
    struct Playlist: Codable {
        let name: String
        let itemIds: [String]
        
    }
    
    // MARK: - Series
    struct Series: Codable, Identifiable {
        let id, title: String
        let genres: [String]?
        let releaseDate: String?
        let thumbnail: String?
        let backgroundImage: String?
        let shortDescription, longDescription: String?
        let tags: [String]?
        let rating: Rating?
        let seasons: [Season]?
        let episodes: [Episode]?
        let content: SeriesContent?
        /// Do not use this property directly, use `type` instead
        private var _type: ItemType? // This will be overwritten when updating data in home feed
        var subtitleURL: URL?
        var releaseYear: String? {
            guard let releaseDate else {
                return nil
            }
            let df = Movie.dateFormater
            df.dateFormat = "yyy-MM-dd"
            let date = df.date(from: releaseDate)
            df.dateFormat = "yyyy"
            return df.string(from: date!)
        }
        
        var videoUrl: String? {
            content?.videoUrl
        }
        
        var duration: Int {
            content?.duration ?? 0
        }
    }
    
    // MARK: - SeriesContent
    struct SeriesContent: Codable {
        let dateAdded: String?
        let videos: [Video]?
        let duration: Int?
        let trickPlayFiles: [TrickPlayFile]?
        let language: Language?
        
        var videoUrl: String? {
            videos?.max()?.url
        }
    }
    
    // MARK: - Episode
    struct Episode: Codable {
        let id: String
        let title: String
        let content: MovieContent?
        let thumbnail: String?
        let episodeNumber: Int?
        let shortDescription, longDescription: String?
        let rating: Rating?
        let releaseDate: String?
        let tags: [Tag]?
        var subtitleURL: URL?
        var videoURL: String? {
            content?.videoUrl
        }
        
        var duration: Int {
            content?.duration ?? 0
        }
    }
    
    enum Tag: String, Codable {
        case animated = "animated"
        case loop = "loop"
        case mini = "mini"
        case short = "short"
    }
    
    // MARK: - Season
    struct Season: Codable {
        let seasonNumber: Int
        let episodes: [Episode]
    }
}

//MARK: - DisplayableItem extensions
extension Feed.Movie: DisplayableItem {
    
    
    var description: String {
        shortDescription ?? ""
    }
    
    var imageUrl: String {
        thumbnail ?? ""
    }
    var backgroundImageURL: String {
        (backgroundImage?.count ?? 0) > 0 ? backgroundImage ?? (thumbnail ?? "") : (thumbnail ?? "")
    }
    
    var type: ItemType {
        .movie
    }
}

extension Feed.Series: DisplayableItem {
    var description: String {
        if let releaseDate {
            var desc = releaseDate
            if let shortDescription {
                desc += "\n\(shortDescription)"
            }
            return desc
        }
        return shortDescription ?? ""
    }
    
    var imageUrl: String {
        thumbnail ?? ""
    }
    var backgroundImageURL: String {
        (backgroundImage?.count ?? 0) > 0 ? backgroundImage ?? (thumbnail ?? "") : (thumbnail ?? "")
    }
    var type: ItemType {
        get {
            _type ?? .series
        } set {
            _type = newValue
        }
    }
}

extension Feed.LiveFeed: DisplayableItem {
//    static func == (lhs: Feed.LiveFeed, rhs: Feed.LiveFeed) -> Bool {
//        lhs
//    }
    
    
    var description: String {
        shortDescription ?? ""
    }
    
    var imageUrl: String {
        thumbnail ?? ""
    }
    var backgroundImageURL: String {
        thumbnail ?? ""
    }
    var type: ItemType {
        .liveTV
    }

}

extension Feed.Episode: DisplayableItem {
    var description: String {
        shortDescription ?? ""
    }
    
    var imageUrl: String {
        thumbnail ?? ""
    }
    var backgroundImageURL: String  {
        thumbnail ?? ""
    }
    var type: ItemType {
        .episode
    }
}
