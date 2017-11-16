//
//  MovieViewModelController.swift
//  Movies
//
//  Created by Arvind Ravi on 16/11/17.
//  Copyright © 2017 Arvind Ravi. All rights reserved.
//

import Foundation

enum ParseError: Error {
  case JSONParsingError
  case MoviesParsingError
}

class MovieViewModelController {
  private var viewModels: [MovieViewModel?] = []
  
  func load(_ completion: @escaping (_ success: Bool, _ error: Error?) -> ()) {
    let urlString = URLs.DefaultURLString + "batman"
    let session = URLSession.shared
    
    guard let url = URL(string: urlString) else {
      completion(false, nil)
      return
    }
    
    let task = session.dataTask(with: url) { [weak self] (data, response, error) in
      guard let strongSelf = self else { return }
      guard let json = data, error == nil else {
        completion(false, error)
        return
      }
      
      guard let moviesResource = MovieViewModelController.parse(json) else {
        completion(false, ParseError.JSONParsingError)
        return
      }
      
      guard let movies = moviesResource.results as? [Movie] else {
        completion(false, ParseError.MoviesParsingError)
        return
      }
      
      strongSelf.viewModels = MovieViewModelController.initViewModels(movies)
      completion(true, nil)
    }
    
    task.resume()
  }
  
  var viewModelsCount: Int {
    return viewModels.count
  }
  
  func viewModel(at index: Int) -> MovieViewModel? {
    guard index > 0 && index < viewModelsCount else { return nil }
    return viewModels[index]
  }
}

private extension MovieViewModelController {
  static func parse(_ json: Data) -> Resource<[Movie]>? {
    do {
      let decoder = JSONDecoder()
      return try decoder.decode(Resource<[Movie]>.self, from: json)
    } catch {
      return nil
    }
  }
  
  static func initViewModels(_ movies: [Movie?]) -> [MovieViewModel?] {
    let movies: [MovieViewModel?] = movies.map { movie in
      if let movie = movie {
        return MovieViewModel(movie: movie)
      } else {
        return nil
      }
    }
    return movies
  }
}
