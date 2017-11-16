//
//  MovieCell.swift
//  Movies
//
//  Created by Arvind Ravi on 16/11/17.
//  Copyright © 2017 Arvind Ravi. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {
  static let identifier = "MovieCell"
  
  func configure(_ movie: MovieViewModel) {
    imageView?.image = #imageLiteral(resourceName: "Placeholder")
    textLabel?.text = movie.title
    isUserInteractionEnabled = false
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    imageView?.image = #imageLiteral(resourceName: "Placeholder")
  }
}
