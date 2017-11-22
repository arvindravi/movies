//
//  MovieViewModelController.swift
//  Movies
//
//  Created by Arvind Ravi on 16/11/17.
//  Copyright © 2017 Arvind Ravi. All rights reserved.
//

import Foundation
import UIKit

enum LoadMoviesError: Error {
  case InvalidQuery
  case InvalidURL
  case InvalidJSON
  case ErrorFetchingData
  case ErrorParsingData(String)
  case NoResultsFound
  case EmptyQuery
}

class MovieViewModelController {
  private var viewModels: [MovieViewModel?] = []
  var currentPage: Int = 1
  var totalPages: Int = 0
  var totalResults: Int = 0
  
  enum Result {
    case Success
    case Failure(LoadMoviesError)
  }
  
  func load(_ query: String = "batman", _ page: Int = 1, _ completion: @escaping (Result) -> ()) throws {
    guard !query.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty else { throw LoadMoviesError.EmptyQuery }
    guard let query = query.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else { throw LoadMoviesError.InvalidQuery }
    let urlString = URLs.DefaultURLString + query + "&page=" + String(page)
    let session = URLSession.shared
    
    guard let url = URL(string: urlString) else { throw LoadMoviesError.InvalidURL }
    
    let task = session.dataTask(with: url) { [weak self] (data, response, error) in
      guard let strongSelf = self else { return }
      guard let json = data, error == nil else {
        completion(.Failure(.InvalidJSON))
        return
      }
      
      // TODO
      guard let moviesResource = MovieViewModelController.parse(json) else {
        completion(.Failure(.ErrorParsingData("moviesResource")))
        return
      }
      
      guard let page = moviesResource.page else {
        completion(.Failure(.ErrorParsingData("page")))
        return
      }
      
      guard let totalPages = moviesResource.totalPages else {
        completion(.Failure(.ErrorParsingData("totalPages")))
        return
      }
      
      guard let totalResults = moviesResource.totalResults else {
        completion(.Failure(.ErrorParsingData("totalResults")))
        return
      }
      
      guard totalResults > 0 else {
        completion(.Failure(.NoResultsFound))
        return
      }
      
      guard let movies = moviesResource.results else {
        completion(.Failure(.ErrorParsingData("movies")))
        return
      }
      
      if page > 1 {
        strongSelf.viewModels.append(contentsOf: MovieViewModelController.initViewModels(movies))
      } else {
        strongSelf.viewModels = MovieViewModelController.initViewModels(movies)
      }
      
      strongSelf.currentPage = page
      strongSelf.totalPages = totalPages
      strongSelf.totalResults = totalResults
      
      completion(.Success)
    }
    
    task.resume()
  }
  
  var viewModelsCount: Int {
    return viewModels.count
  }
  
  func viewModel(at index: Int) -> MovieViewModel? {
    guard index >= 0 && index < viewModelsCount else { return nil }
    return viewModels[index]
  }
  
  func flush() {
    viewModels.removeAll()
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
