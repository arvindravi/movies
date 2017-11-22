//
//  Movie.swift
//  Movies
//
//  Created by Arvind Ravi on 14/11/17.
//  Copyright © 2017 Arvind Ravi. All rights reserved.
//

import Foundation
import UIKit

struct Movie: Decodable {
  let voteCount: Int
  let id: Int
  let title: String
  let originalTitle: String
  let popularity: Double
  let posterPath: String
  let backdropPath: String
  let overview: String
  let releaseDate: Date
  
  var image: UIImage?
  
  private enum CodingKeys: String, CodingKey {
    case id, title, popularity, overview
    case voteCount     = "vote_count"
    case originalTitle = "original_title"
    case posterPath    = "poster_path"
    case backdropPath  = "backdrop_path"
    case releaseDate   = "release_date"
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    voteCount = try values.decode(Int.self, forKey: .voteCount)
    id = try values.decode(Int.self, forKey: .id)
    title = try values.decodeIfPresent(String.self, forKey: .title) ?? ""
    originalTitle = try values.decodeIfPresent(String.self, forKey: .originalTitle) ?? ""
    popularity = try values.decode(Double.self, forKey: .popularity)
    posterPath = try values.decodeIfPresent(String.self, forKey: .posterPath) ?? ""
    backdropPath = try values.decodeIfPresent(String.self, forKey: .backdropPath) ?? ""
    overview = try values.decodeIfPresent(String.self, forKey: .overview) ?? ""
    
    let releaseDateString = try values.decodeIfPresent(String.self, forKey: .releaseDate) ?? ""
    releaseDate = Date.from(string: releaseDateString) ?? Date()
    image = nil
  }
}
