//
//  ItemCategory.swift
//  NeoDB
//
//  Created by citron on 1/15/25.
//

import Foundation

enum ItemCategory: String, Codable, CaseIterable {
    case book
    case movie
    case tv
    case tvSeason
    case tvEpisode
    case music
    case game
    case podcast
    case performance
    case performanceProduction
    case fanfic
    case exhibition
    case collection
    
//    var rawValue: String {
//        switch self {
//        case .tvSeason, .tvEpisode:
//            return "tv"
//        case .performanceProduction:
//            return "performance"
//        default:
//            return String(describing: self)
//        }
//    }
    
    var urlPath: String {
        switch self {
        case .tvSeason, .tvEpisode:
            return "tv"
        case .performanceProduction:
            return "performance"
        default:
            return self.rawValue
        }
    }
}
