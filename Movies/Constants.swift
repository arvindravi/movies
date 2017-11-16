//
//  Constants.swift
//  Movies
//
//  Created by Arvind Ravi on 15/11/17.
//  Copyright © 2017 Arvind Ravi. All rights reserved.
//

// let APIKey = "2696829a81b1b5827d515ff121700838"
// let query = "batman"
// let page = 1
// let url = URL(string: "http://api.themoviedb.org/3/search/movie?api_key=\(APIKey)&query=\(query)&page=\(page)")!

// API Key: 2696829a81b1b5827d515ff121700838

// Search:
// http://api.themoviedb.org/3/search/movie

// Image:
// http://image.tmdb.org/t/p/w92/<posterPath.jpg>

// Poster Path:
// kuqbKnzULGFDZEBrOjQooBray5w.jpg

import Foundation

// Keys
struct K {
  struct API {
    static let TheMovieDB = "2696829a81b1b5827d515ff121700838"
  }
}

// URLs
struct URLs {
  struct BaseEndpoint {
    static let Search = "http://api.themoviedb.org/3/search/movie"
    static let Image = "http://image.tmdb.org/t/p/w92/"
  }
  static let DefaultURLString = BaseEndpoint.Search + "?api_key=" + K.API.TheMovieDB + "&query="
}
