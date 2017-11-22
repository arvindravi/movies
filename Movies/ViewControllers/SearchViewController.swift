//
//  SearchViewController.swift
//  Movies
//
//  Created by Arvind Ravi on 17/11/17.
//  Copyright © 2017 Arvind Ravi. All rights reserved.
//

import UIKit

class SearchViewController: UITableViewController {
  
  // MARK: - Properties
  fileprivate var controller = MovieViewModelController()
  fileprivate var recentSearchQueries = [String]() {
    didSet {
      tableView.reloadData()
    }
  }
  
  var currentSearchQuery: String = ""
  var searchController: UISearchController!
  var resultsViewController: UIViewController!
  
  // MARK: - Lifecycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    UserDefaults.standard.set(recentSearchQueries, forKey: kRecentSearchQueriesKey)
  }
  
  // MARK: - Methods
  func setup() {
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SearchResultTableViewCell")
    setupUI()
    setupSearch()
    loadRecentSearchQueries()
  }
  
  func setupUI() {
    navigationItem.title = "Search"
    guard let navigationBar = navigationController?.navigationBar else { return }
    if #available(iOS 11, *) {
      navigationBar.prefersLargeTitles = true
    }
  }
  
  func setupSearch() {
    // Setup Search
    resultsViewController = UINavigationController(rootViewController: MoviesViewController())
    searchController = UISearchController(searchResultsController: resultsViewController)
    searchController.searchBar.delegate = self
    
    if #available(iOS 9.1, *) {
      searchController.obscuresBackgroundDuringPresentation = false
    } else {
      searchController.dimsBackgroundDuringPresentation = false
    }
    
    definesPresentationContext = true
    
    if #available(iOS 11, *) {
      self.navigationItem.searchController = searchController
      self.navigationItem.hidesSearchBarWhenScrolling = false
    } else {
      tableView.tableHeaderView = searchController.searchBar
    }
  }
  
  func loadRecentSearchQueries() {
    guard let recentSearchQueries = UserDefaults.standard.value(forKey: kRecentSearchQueriesKey) as? [String] else { return }
    self.recentSearchQueries = recentSearchQueries
  }
  
  @objc
  private func loadMovies() {
    guard !currentSearchQuery.isEmpty, currentSearchQuery.characters.count > 1 else { return }
    guard let moviesNavController = searchController.searchResultsController as? UINavigationController,
    let moviesVC = moviesNavController.topViewController as? MoviesViewController else { return }
    moviesVC.query = currentSearchQuery
    moviesVC.loadMovies() { success in
      DispatchQueue.main.async {
        guard success == true else { return }
        
        // Remove Search Term is already present
        if self.recentSearchQueries.contains(self.currentSearchQuery) {
          if let index = self.recentSearchQueries.index(of: self.currentSearchQuery) {
            self.recentSearchQueries.remove(at: index)
          }
        }
        
        // Add it to recent searches
        if self.recentSearchQueries.count >= kRecentSearchTermsCount {
          self.recentSearchQueries.shiftRight()
          self.recentSearchQueries.removeFirst()
        }
        self.recentSearchQueries.insert(self.currentSearchQuery, at: 0)
      }
    }
  }
}
  
// MARK: - Data Source Methods
extension SearchViewController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return recentSearchQueries.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultTableViewCell", for: indexPath)
    cell.textLabel?.text = recentSearchQueries[indexPath.row]
    return cell
  }
}

// MARK: - Delegate Methods
extension SearchViewController {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let query = recentSearchQueries[indexPath.row]
    searchController.searchBar.text = query
    searchController.isActive = true
    searchBarSearchButtonClicked(searchController.searchBar)
  }
}

extension SearchViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let query = searchBar.text else { return }
    currentSearchQuery = query
    loadMovies()
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    guard searchText.isEmpty else { return }
    guard let moviesNavController = searchController.searchResultsController as? UINavigationController,
    let moviesVC = moviesNavController.topViewController as? MoviesViewController else { return }
    moviesVC.flushData()
  }
}
