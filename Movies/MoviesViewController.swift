//
//  _MoviesViewController.swift
//  Movies
//
//  Created by Arvind Ravi on 16/11/17.
//  Copyright © 2017 Arvind Ravi. All rights reserved.
//

import UIKit

class MoviesViewController: UITableViewController {
  
  // MARK: - Properties
  fileprivate var controller = MovieViewModelController()
  fileprivate let operationQueue = OperationQueue()
  fileprivate var operations = [IndexPath: ImageOperation]()
  
  // Search
  let searchController = UISearchController(searchResultsController: nil)
  let spinner: UIActivityIndicatorView = {
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    spinner.hidesWhenStopped = true
    return spinner
  }()
  var currentSearchQuery: String = "batman"
  
  // Lifecycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  // Setup
  func setup() {
    setupUI()
    loadMovies()
    setupSearch()
    setupTableView()
  }
  
  func setupUI() {
    navigationItem.title = "Movies"
    guard let navigationBar = navigationController?.navigationBar else { return }
    if #available(iOS 11, *) {
      navigationBar.prefersLargeTitles = true
    }
  }
  
  
  
  func loadMovies(page: Int = 1) {
    do {
      try controller.load(currentSearchQuery, page) { [weak self] (result) in
        var title: String = "Error"
        var message: String = ""
        switch result {
        case .Success:
          DispatchQueue.main.async {
            self?.spinner.stopAnimating()
            self?.tableView.reloadData()
          }
        case .Failure(let error):
          switch error {
          case .NoResultsFound:
            title = ErrorMessages.NoMoviesFound.title
            message = ErrorMessages.NoMoviesFound.message
          case .ErrorParsingData(let data):
            title = ErrorMessages.ParseError.title
            message = ErrorMessages.ParseError.message + data
          default: self?.showAlert(title, message: error.localizedDescription)
          }
          self?.showAlert(title, message: message)
        }
      }
    } catch LoadMoviesError.EmptyQuery {
      showAlert(ErrorMessages.EmptyQuery.title, message: ErrorMessages.EmptyQuery.message)
    } catch LoadMoviesError.InvalidQuery {
      showAlert(ErrorMessages.InvalidQuery.title, message: ErrorMessages.InvalidQuery.message)
    } catch LoadMoviesError.InvalidURL {
      showAlert(ErrorMessages.InvalidURL.title, message: ErrorMessages.InvalidURL.message)
    } catch {
      showAlert("Error", message: error.localizedDescription)
    }
  }
  
  func setupSearch() {
    // Setup Spinner
    spinner.center = self.view.center
    tableView.addSubview(spinner)
    
    // Setup Search
    searchController.dimsBackgroundDuringPresentation = false
    searchController.searchResultsUpdater = self
    searchController.searchBar.delegate = self
    
    definesPresentationContext = true
    
    if #available(iOS 11, *) {
      self.navigationItem.searchController = searchController
      self.navigationItem.hidesSearchBarWhenScrolling = false
    } else {
      tableView.tableHeaderView = searchController.searchBar
    }
  }
  
  func setupTableView() {
    tableView.register(MovieCell.self, forCellReuseIdentifier: MovieCell.identifier)
    tableView.prefetchDataSource = self
    automaticallyAdjustsScrollViewInsets = true
  }
}

// Async Image Load
typealias Operations = [IndexPath: ImageOperation]
extension MoviesViewController {
  private func loadImage(for cell: MovieCell, with viewModel: MovieViewModel, at indexPath: IndexPath) {
    if let operation = operations[indexPath] {
      guard let image = operation.image else { return }
      DispatchQueue.main.async {
        cell.imageView?.image = image
      }
    } else {
      guard let url = URL(string: URLs.BaseEndpoint.Image + viewModel.posterPath) else { return }
      let operation = ImageOperation(url: url)
      operation.completionHandler = { [weak self] (image) in
        guard let strongSelf = self else { return }
        DispatchQueue.main.async {
          cell.imageView?.image = image
        }
        strongSelf.operations.removeValue(forKey: indexPath)
      }
      operationQueue.addOperation(operation)
      operations[indexPath] = operation
    }
  }
}

extension MoviesViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    spinner.startAnimating()
    
    let searchBar = searchController.searchBar
    guard let query = searchBar.text else { return }
    
    self.currentSearchQuery = query
    loadMovies()
  }
}

extension MoviesViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    print("updateSearchResults")
  }
}

// Prefetching
extension MoviesViewController: UITableViewDataSourcePrefetching {
  private func prefetchMovie(at indexPath: IndexPath) {
    if let _ = operations[indexPath] { return }
    guard let viewModel = controller.viewModel(at: indexPath.row) else { return }
    guard let url = URL(string: URLs.BaseEndpoint.Image + viewModel.posterPath) else { return }
    let operation = ImageOperation(url: url)
    operationQueue.addOperation(operation)
    operations[indexPath] = operation
  }
  
  private func cancelPrefetching(for indexPath: IndexPath) {
    guard let operation = operations[indexPath] else { return }
    operation.cancel()
    operations.removeValue(forKey: indexPath)
  }
  
  func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach {
      prefetchMovie(at: $0)
      
      print(String.init(format: "prefetchRowsAt #%i", $0.row))
    }
  }
  
  func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach {
      cancelPrefetching(for: $0)
    }
  }
}

// Datasource Methods
extension MoviesViewController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return controller.viewModelsCount
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: MovieCell.identifier) as! MovieCell
    if let viewModel = controller.viewModel(at: indexPath.row) {
      cell.configure(viewModel)
      loadImage(for: cell, with: viewModel, at: indexPath)
    }
    return cell
  }
}

// Delegate Methods
extension MoviesViewController {
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 200
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if indexPath.row == controller.viewModelsCount - 1 {
      let currentPage = controller.currentPage
      let totalPages = controller.totalPages
      guard currentPage < totalPages else { return }
      
      // TODO: Refactor
      loadMovies(page: currentPage + 1)
    }
  }
  
  override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let operation = operations[indexPath] else { return }
    operation.cancel()
    operations.removeValue(forKey: indexPath)
  }
}
