//
//  MainViewController.swift
//  Movies
//
//  Created by Arvind Ravi on 17/11/17.
//  Copyright © 2017 Arvind Ravi. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  func setup() {    
    // VCs
    let moviesVC = UINavigationController(rootViewController: MoviesViewController())
    moviesVC.tabBarItem = UITabBarItem.init(tabBarSystemItem: .featured, tag: 0)
    
    let searchVC = UINavigationController(rootViewController: SearchViewController())
    searchVC.tabBarItem = UITabBarItem.init(tabBarSystemItem: .search, tag: 1)
    
    viewControllers = [moviesVC, searchVC]
  }
}
