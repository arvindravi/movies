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
  let searchController: UISearchController = {
    let searchController = UISearchController(searchResultsController: nil)
    searchController.dimsBackgroundDuringPresentation = false
    return searchController
  }()
  
  // Lifecycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  //
  func setup() {
    loadMovies()
    setupSearch()
    setupTableView()
  }
  
  func loadMovies() {
    controller.load { [weak self] (success, error) in
      guard success == true else {
        // Display Error
        print(error.debugDescription)
        return
      }
      
      DispatchQueue.main.async {
        self?.tableView.reloadData()
      }
    }
  }
  
  func setupSearch() {
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

// Datasource
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

// Delegates
extension MoviesViewController {
  override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let operation = operations[indexPath] else { return }
    operation.cancel()
    operations.removeValue(forKey: indexPath)
  }
}
