//
//  MastodonPoll.swift
//  NeoDB
//
//  Created by citron on 1/13/25.
//

import Foundation

public struct MastodonPoll: Codable {
  public struct Option: Identifiable, Codable {
    enum CodingKeys: String, CodingKey {
      case title, votesCount
    }
    
    public var id = UUID().uuidString
    public let title: String
    public let votesCount: Int
  }
  
  public let id: String
  public let expiresAt: ServerDate
  public let expired: Bool
  public let multiple: Bool
  public let votesCount: Int
  public let votersCount: Int?
  public let voted: Bool
  public let ownVotes: [Int]
  public let options: [Option]
}
