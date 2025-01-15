//
//  Item.swift
//  NeoDB
//
//  Created by citron on 1/15/25.
//

// MARK: - Base Item Schema
struct ItemSchema: Codable, Hashable {
    let title: String
    let description: String
    let localizedTitle: [LocalizedTitleSchema]
    let localizedDescription: [LocalizedTitleSchema]
    let coverImageUrl: String?
    let rating: Double?
    let ratingCount: Int?
    let id: String
    let type: String
    let uuid: String
    let url: String
    let apiUrl: String
    let category: ItemCategory
    let parentUuid: String?
    let displayTitle: String
    let externalResources: [ExternalResourceSchema]?
    let brief: String?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ItemSchema, rhs: ItemSchema) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Edition Schema
struct EditionSchema: Codable {
    let id: String
    let type: String
    let uuid: String
    let url: String
    let apiUrl: String
    let category: ItemCategory
    let parentUuid: String?
    let displayTitle: String
    let externalResources: [ExternalResourceSchema]?
    let title: String
    let description: String
    let localizedTitle: [LocalizedTitleSchema]
    let localizedDescription: [LocalizedTitleSchema]
    let coverImageUrl: String?
    let rating: Double?
    let ratingCount: Int?
    let subtitle: String?
    let origTitle: String?
    let author: [String]
    let translator: [String]
    let language: [String]
    let pubHouse: String?
    let pubYear: Int?
    let pubMonth: Int?
    let binding: String?
    let price: String?
    let pages: Int?
    let series: String?
    let imprint: String?
    let isbn: String?
}

// MARK: - Movie Schema
struct MovieSchema: Codable {
    let id: String
    let type: String
    let uuid: String
    let url: String
    let apiUrl: String
    let category: ItemCategory
    let parentUuid: String?
    let displayTitle: String
    let externalResources: [ExternalResourceSchema]?
    let title: String
    let description: String
    let localizedTitle: [LocalizedTitleSchema]
    let localizedDescription: [LocalizedTitleSchema]
    let coverImageUrl: String?
    let rating: Double?
    let ratingCount: Int?
    let origTitle: String?
    let otherTitle: [String]
    let director: [String]
    let playwright: [String]
    let actor: [String]
    let genre: [String]
    let language: [String]
    let area: [String]
    let year: Int?
    let site: String?
    let duration: String?
    let imdb: String?
}

// MARK: - TV Show Schema
struct TVShowSchema: Codable {
    let id: String
    let type: String
    let uuid: String
    let url: String
    let apiUrl: String
    let category: ItemCategory
    let parentUuid: String?
    let displayTitle: String
    let externalResources: [ExternalResourceSchema]?
    let title: String
    let description: String
    let localizedTitle: [LocalizedTitleSchema]
    let localizedDescription: [LocalizedTitleSchema]
    let coverImageUrl: String?
    let rating: Double?
    let ratingCount: Int?
    let seasonCount: Int?
    let origTitle: String?
    let otherTitle: [String]
    let director: [String]
    let playwright: [String]
    let actor: [String]
    let genre: [String]
    let language: [String]
    let area: [String]
    let year: Int?
    let site: String?
    let episodeCount: Int?
    let imdb: String?
}

// MARK: - TV Season Schema
struct TVSeasonSchema: Codable {
    let id: String
    let type: String
    let uuid: String
    let url: String
    let apiUrl: String
    let category: ItemCategory
    let parentUuid: String?
    let displayTitle: String
    let externalResources: [ExternalResourceSchema]?
    let title: String
    let description: String
    let localizedTitle: [LocalizedTitleSchema]
    let localizedDescription: [LocalizedTitleSchema]
    let coverImageUrl: String?
    let rating: Double?
    let ratingCount: Int?
    let seasonNumber: Int?
    let origTitle: String?
    let otherTitle: [String]
    let director: [String]
    let playwright: [String]
    let actor: [String]
    let genre: [String]
    let language: [String]
    let area: [String]
    let year: Int?
    let site: String?
    let episodeCount: Int?
    let episodeUuids: [String]
    let imdb: String?
}

// MARK: - TV Episode Schema
struct TVEpisodeSchema: Codable {
    let title: String
    let description: String
    let localizedTitle: [LocalizedTitleSchema]
    let localizedDescription: [LocalizedTitleSchema]
    let coverImageUrl: String?
    let rating: Double?
    let ratingCount: Int?
    let id: String
    let type: String
    let uuid: String
    let url: String
    let apiUrl: String
    let category: ItemCategory
    let parentUuid: String?
    let displayTitle: String
    let externalResources: [ExternalResourceSchema]?
    let episodeNumber: Int?
}

// MARK: - Album Schema
struct AlbumSchema: Codable {
    let id: String
    let type: String
    let uuid: String
    let url: String
    let apiUrl: String
    let category: ItemCategory
    let parentUuid: String?
    let displayTitle: String
    let externalResources: [ExternalResourceSchema]?
    let title: String
    let description: String
    let localizedTitle: [LocalizedTitleSchema]
    let localizedDescription: [LocalizedTitleSchema]
    let coverImageUrl: String?
    let rating: Double?
    let ratingCount: Int?
    let otherTitle: [String]
    let genre: [String]
    let artist: [String]
    let company: [String]
    let duration: Int?
    let releaseDate: String?
    let trackList: String?
    let barcode: String?
}

// MARK: - Podcast Schema
struct PodcastSchema: Codable {
    let id: String
    let type: String
    let uuid: String
    let url: String
    let apiUrl: String
    let category: ItemCategory
    let parentUuid: String?
    let displayTitle: String
    let externalResources: [ExternalResourceSchema]?
    let title: String
    let description: String
    let localizedTitle: [LocalizedTitleSchema]
    let localizedDescription: [LocalizedTitleSchema]
    let coverImageUrl: String?
    let rating: Double?
    let ratingCount: Int?
    let host: [String]
    let genre: [String]
    let language: [String]
    let episodeCount: Int?
    let lastEpisodeDate: String?
    let rssUrl: String?
    let websiteUrl: String?
}

// MARK: - Game Schema
struct GameSchema: Codable {
    let id: String
    let type: String
    let uuid: String
    let url: String
    let apiUrl: String
    let category: ItemCategory
    let parentUuid: String?
    let displayTitle: String
    let externalResources: [ExternalResourceSchema]?
    let title: String
    let description: String
    let localizedTitle: [LocalizedTitleSchema]
    let localizedDescription: [LocalizedTitleSchema]
    let coverImageUrl: String?
    let rating: Double?
    let ratingCount: Int?
    let genre: [String]
    let developer: [String]
    let publisher: [String]
    let platform: [String]
    let releaseType: String?
    let releaseDate: String?
    let officialSite: String?
}

// MARK: - Performance Schema
struct PerformanceSchema: Codable {
    let title: String
    let description: String
    let localizedTitle: [LocalizedTitleSchema]
    let localizedDescription: [LocalizedTitleSchema]
    let coverImageUrl: String?
    let rating: Double?
    let ratingCount: Int?
    let id: String
    let type: String
    let uuid: String
    let url: String
    let apiUrl: String
    let category: ItemCategory
    let parentUuid: String?
    let displayTitle: String
    let externalResources: [ExternalResourceSchema]?
    let origTitle: String?
    let otherTitle: [String]
    let genre: [String]
    let language: [String]
    let openingDate: String?
    let closingDate: String?
    let director: [String]
    let playwright: [String]
    let origCreator: [String]
    let composer: [String]
    let choreographer: [String]
    let performer: [String]
    let actor: [CrewMemberSchema]
    let crew: [CrewMemberSchema]
    let officialSite: String?
}

// MARK: - Performance Production Schema
struct PerformanceProductionSchema: Codable {
    let title: String
    let description: String
    let localizedTitle: [LocalizedTitleSchema]
    let localizedDescription: [LocalizedTitleSchema]
    let coverImageUrl: String?
    let rating: Double?
    let ratingCount: Int?
    let id: String
    let type: String
    let uuid: String
    let url: String
    let apiUrl: String
    let category: ItemCategory
    let parentUuid: String?
    let displayTitle: String
    let externalResources: [ExternalResourceSchema]?
    let origTitle: String?
    let otherTitle: [String]
    let language: [String]
    let openingDate: String?
    let closingDate: String?
    let director: [String]
    let playwright: [String]
    let origCreator: [String]
    let composer: [String]
    let choreographer: [String]
    let performer: [String]
    let actor: [CrewMemberSchema]
    let crew: [CrewMemberSchema]
    let officialSite: String?
}
