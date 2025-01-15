//
//  OpenURL.swift
//  NeoDB
//
//  Created by citron on 1/15/25.
//

import Foundation
import OSLog

class URLHandler {
    private static let logger = Logger.services.urlHandler
    private static let neodbItemIdentifier = "~neodb~"
    private static let isDebugLoggingEnabled = false

    private static func log(_ message: String) {
        guard isDebugLoggingEnabled else { return }
        logger.debug("\(message)")
    }

    static func handleItemURL(
        _ url: URL, completion: @escaping (RouterDestination?) -> Void
    ) {
        guard
            let components = URLComponents(
                url: url, resolvingAgainstBaseURL: true),
            components.path.contains(neodbItemIdentifier)
        else {
            log("Not a NeoDB URL: \(url.absoluteString)")
            completion(nil)
            return
        }

        // Remove leading slash and split path
        let path = components.path.dropFirst()
        let pathComponents = path.split(separator: "/").map(String.init)

        // Verify we have ~neodb~/type/id format
        guard pathComponents.count >= 3,
            pathComponents[0] == neodbItemIdentifier
        else {
            log("Invalid NeoDB URL format: \(components.path)")
            completion(nil)
            return
        }

        let type = pathComponents[1]
        let id = pathComponents[2]

        // Handle special cases for tv seasons and episodes
        let category: ItemCategory
        if type == "tv" && pathComponents.count >= 4 {
            switch pathComponents[2] {
            case "season":
                category = .tvSeason
            case "episode":
                category = .tvEpisode
            default:
                category = .tv
            }
        } else if type == "album" {
            category = .music
        } else if type == "performance" && pathComponents[2] == "production" {
            category = .performanceProduction
        } else if let itemCategory = ItemCategory(rawValue: type) {
            category = itemCategory
        } else {
            log("Unknown item type: \(type), defaulting to book")
            category = .book
        }

        log("Processing NeoDB URL - type: \(type), id: \(id)")

        // Create item URL by removing ~neodb~
        var itemComponents = components
        itemComponents.path = itemComponents.path.replacingOccurrences(
            of: "/\(neodbItemIdentifier)", with: "")

        // Create API URL by replacing ~neodb~ with api
        var apiComponents = components
        apiComponents.path = apiComponents.path.replacingOccurrences(
            of: "/\(neodbItemIdentifier)", with: "/api")

        // Create a temporary ItemSchema
        let tempItem = ItemSchema(
            id: id,
            type: type,
            uuid: id,
            url: itemComponents.url?.absoluteString ?? url.absoluteString,
            apiUrl: apiComponents.url?.absoluteString ?? url.absoluteString,
            category: category,
            parentUuid: nil,
            displayTitle: id,
            externalResources: nil,
            title: id,
            description: url.absoluteString,
            localizedTitle: nil,
            localizedDescription: nil,
            coverImageUrl: nil,
            rating: nil,
            ratingCount: nil,
            brief: type
        )

        log("Created ItemSchema for \(category.rawValue)")
        completion(.itemDetailWithItem(item: tempItem))
    }
}
