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
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: UITableViewCellStyle.value1, reuseIdentifier: reuseIdentifier)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(_ movie: MovieViewModel) {
    imageView?.image = #imageLiteral(resourceName: "NoImagePlaceholder")
    textLabel?.text = movie.title
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    imageView?.image = #imageLiteral(resourceName: "Placeholder")
    textLabel?.text = ""
  }
}
