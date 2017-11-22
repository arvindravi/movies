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
  public var query: String = ""
  
  fileprivate var controller = MovieViewModelController()
  fileprivate let operationQueue = OperationQueue()
  fileprivate var operations = [IndexPath: ImageOperation]()
  
  let spinner: UIActivityIndicatorView = {
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    spinner.hidesWhenStopped = true
    return spinner
  }()
  
  // Infinite Scroll
  let footerSpinner: UIActivityIndicatorView = {
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    spinner.hidesWhenStopped = true
    return spinner
  }()
  
  // Lifecycle Methods
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    loadMovies() { _ in }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    flushData()
  }
  
  // Setup
  func setup() {
    query = (parent is UINavigationController) ? "batman" : ""
    setupUI() // TODO: Refactor to Styles.swift
    setupTableView()
  }
  
  func setupUI() {
    navigationItem.title = (parent?.parent is UISearchController) ? "" : "Movies"
    guard let navigationBar = navigationController?.navigationBar else { return }
    if #available(iOS 11, *) {
      navigationBar.prefersLargeTitles = !(parent?.parent is UISearchController)
    }
  }
  
  func loadMovies(page: Int = 1, completion: @escaping (Bool) -> ()) {
    guard !query.isEmpty else { return }
    spinner.startAnimating()
    do {
      try controller.load(query, page) { [weak self] (result) in
        switch result {
        case .Success:
          DispatchQueue.main.async {
            if page > 1 { // didLoad additional page
              self?.footerSpinner.stopAnimating()
              self?.tableView.tableFooterView = nil
            }
            self?.spinner.stopAnimating()
            self?.tableView.reloadData()
          }
          completion(true)
        case .Failure(let error):
          var title: String = "Error"
          var message: String = ""
          switch error {
          case .NoResultsFound:
            title = ErrorMessages.NoMoviesFound.title
            message = ErrorMessages.NoMoviesFound.message
          case .ErrorParsingData(let data):
            title = ErrorMessages.ParseError.title
            message = ErrorMessages.ParseError.message + data
          default: self?.showAlert(title, message: error.localizedDescription)
          }
          DispatchQueue.main.async {
            self?.spinner.stopAnimating()
            self?.showAlert(title, message: message)
          }
          completion(false)
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
  
  func setupTableView() {
    spinner.center = tableView.center
    tableView.addSubview(spinner)
    
    tableView.register(MovieCell.self, forCellReuseIdentifier: MovieCell.identifier)
    automaticallyAdjustsScrollViewInsets = true
    
    // Spinner - Footer View (Infinite Scroll)
    footerSpinner.frame = CGRect(x: 0, y: 0, width: 320, height: 44)
    tableView.tableFooterView = footerSpinner
    
    // Prefetch
    if #available(iOS 10, *) {
      tableView.prefetchDataSource = self
    }
  }
  
  func flushData() {
    controller.flush()
    tableView.reloadData()
  }
}

// Async Image Load
extension MoviesViewController {
  private func loadImage(for cell: MovieCell, with viewModel: MovieViewModel, at indexPath: IndexPath) {
    if let operation = operations[indexPath] {
      guard let image = operation.image else { return }
      DispatchQueue.main.async {
        cell.imageView?.image = image
        cell.setNeedsLayout()
      }
    } else {
      guard let url = URL(string: URLs.BaseEndpoint.Image + viewModel.posterPath) else { return }
      let operation = ImageOperation(url: url)
      operation.completionHandler = { [weak self] (image) in
        guard let strongSelf = self else { return }
        DispatchQueue.main.async {
          cell.imageView?.image = image
          cell.setNeedsLayout()
        }
        strongSelf.operations.removeValue(forKey: indexPath)
      }
      operationQueue.addOperation(operation)
      operations[indexPath] = operation
    }
  }
}


// MARK: - Prefetching
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
    }
  }
  
  func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach {
      cancelPrefetching(for: $0)
    }
  }
}

// MARK: - Datasource Methods
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

// MARK: - Delegate Methods
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
      tableView.tableFooterView = footerSpinner
      footerSpinner.startAnimating()
      
      loadMovies(page: currentPage + 1) { _ in }
    }
  }
  
  override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let operation = operations[indexPath] else { return }
    operation.cancel()
    operations.removeValue(forKey: indexPath)
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let movieViewModel = controller.viewModel(at: indexPath.row) else { return }
    let detailVC = MovieDetailViewController(style: .grouped)
    detailVC.movie = movieViewModel
    detailVC.navigationItem.title = movieViewModel.title
    show(detailVC, sender: nil)
  }
}
