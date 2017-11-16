//
//  MovieViewModel.swift
//  Movies
//
//  Created by Arvind Ravi on 16/11/17.
//  Copyright © 2017 Arvind Ravi. All rights reserved.
//

import Foundation

struct MovieViewModel {
  let voteCount: Int
  let id: Int
  let title: String
  let originalTitle: String
  let popularity: Double
  let posterPath: String
  let backdropPath: String
  let overview: String
  
  init(movie: Movie) {
    voteCount = movie.voteCount
    id = movie.id
    title = movie.title
    originalTitle = movie.originalTitle
    popularity = movie.popularity
    posterPath = movie.posterPath
    backdropPath = movie.backdropPath
    overview = movie.overview
  }
}
