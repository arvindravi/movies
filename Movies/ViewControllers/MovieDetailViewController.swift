//
//  _MovieDetailViewController.swift
//  Movies
//
//  Created by Arvind Ravi on 21/11/17.
//  Copyright © 2017 Arvind Ravi. All rights reserved.
//

import UIKit

class MovieDetailViewController: UITableViewController {
  
  // MARK: - Properties
  var movie: MovieViewModel?
  fileprivate let operationQueue = OperationQueue()
  fileprivate var operations = [IndexPath: ImageOperation]()
  fileprivate var searchControllerWhenPresented: UISearchController?
  
  let cells: [String] = ["ImageCell", "TitleCell", "ReleaseDateCell", "OverviewCell", "PopularityCell", "VoteCountCell"]
  
  override init(style: UITableViewStyle) {
    super.init(style: UITableViewStyle.grouped)
    cells.forEach { tableView.register(UITableViewCell.self, forCellReuseIdentifier: $0) }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    /*
    / Rough implementation to avoid using a custom transition to mimick Calendar/Phone app.
    / Refer: https://github.com/PetahChristian/SearchResultsCustomTransition/blob/master/README.md
    */
    guard let navigationControllerWhenPresented = parent as? UINavigationController else { return }
    guard let searchController = navigationControllerWhenPresented.parent as? UISearchController else { return }
    searchControllerWhenPresented = searchController
    animateSearchBar(for: searchControllerWhenPresented)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    animateSearchBar(for: searchControllerWhenPresented)
  }
  
  private func animateSearchBar(for searchController: UISearchController?) {
    guard let searchController = searchController else { return }
    UIView.animate(withDuration: 0.2, animations: {
      searchController.searchBar.superview?.alpha = (searchController.searchBar.superview?.alpha == 0) ? 1 : 0
    }) { (true) in
      if true { searchController.searchBar.superview?.isHidden = !(searchController.searchBar.superview?.isHidden)! }
    }
  }
}

extension MovieDetailViewController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return cells.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let identifier = cells[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    configure(cell: cell, with: identifier, at: indexPath)
    return cell
  }
}

extension MovieDetailViewController { // TODO
  private func loadImage(for cell: UITableViewCell, with viewModel: MovieViewModel, at indexPath: IndexPath) {
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

  private func configure(cell: UITableViewCell, with identifier: String, at indexPath: IndexPath) {
    guard let movie = movie else { return }
    switch identifier {
    case "ImageCell":
      cell.imageView?.image = #imageLiteral(resourceName: "Placeholder")
      loadImage(for: cell, with: movie, at: indexPath)
    case "TitleCell":
      cell.textLabel?.text = "Title: \(movie.title)"
    case "ReleaseDateCell":
      let calendar = Calendar.current
      let date = movie.releaseDate
      let year = calendar.component(.year, from: date)
      let month = calendar.component(.month, from: date)
      let day = calendar.component(.day, from: date)
      cell.textLabel?.text = "Release Date: \(day)/\(month)/\(year)"
    case "OverviewCell":
      let textView = UITextView(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height))
      textView.text = "Overview: \(movie.overview)"
      textView.font = UIFont.systemFont(ofSize: 17)
      cell.contentView.addSubview(textView)
    case "PopularityCell":
      cell.textLabel?.text = "Popularity: \(String(describing: movie.popularity))"
    case "VoteCountCell":
      cell.textLabel?.text = "Votes: \(movie.voteCount)"
    default:
      break
    }
  }
}

extension MovieDetailViewController {
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let identifier = cells[indexPath.row]
    switch identifier {
    case "ImageCell": return 200
    case "OverviewCell": return 200
    default: return 50
    }
  }
}
