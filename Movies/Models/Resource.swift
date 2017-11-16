//
//  Resource.swift
//  Movies
//
//  Created by Arvind Ravi on 14/11/17.
//  Copyright © 2017 Arvind Ravi. All rights reserved.
//

import Foundation
import UIKit

//let APIKey = "2696829a81b1b5827d515ff121700838"
//let query = "batman"
//let page = 1
//
//let url = URL(string: "http://api.themoviedb.org/3/search/movie?api_key=\(APIKey)&query=\(query)&page=\(page)")!

struct Resource<A: Decodable>: Decodable {
  var url: URL?
  
  let page: Int?
  let totalResults: Int?
  let totalPages: Int?
  let results: A?
  
  var mediaURLs: [URL]?
  
  private enum CodingKeys: String, CodingKey {
    case page
    case totalResults = "total_results"
    case totalPages = "total_pages"
    case additionalKeys = "results"
  }
  
  enum AdditionalInfoKeys: String, CodingKey {
    case results
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    page = try values.decode(Int.self, forKey: .page)
    totalResults = try values.decode(Int.self, forKey: .totalResults)
    totalPages = try values.decode(Int.self, forKey: .totalPages)
    results = try values.decode(A.self, forKey: .additionalKeys)
    mediaURLs = nil
  }
}

extension Resource {
  init(url: URL) {
    self.url = url
    self.page = nil
    self.totalResults = nil
    self.totalPages = nil
    self.results = nil
  }
}
