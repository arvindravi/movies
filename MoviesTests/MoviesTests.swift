//
//  MoviesTests.swift
//  MoviesTests
//
//  Created by Arvind Ravi on 17/11/17.
//  Copyright © 2017 Arvind Ravi. All rights reserved.
//

import XCTest
@testable import Movies

class MoviesTests: XCTestCase {
  
  fileprivate var moviesVC: MoviesViewController!
  fileprivate var controller: MovieViewModelController!
  
  override func setUp() {
    super.setUp()
    moviesVC = MoviesViewController()
    controller = MovieViewModelController()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testLoadMovies() {
    let expectation = self.expectation(description: "Loads Movies")
    moviesVC.query = "batman"
    moviesVC.loadMovies { (success) in
      if success {
        expectation.fulfill()
      } else {
        XCTFail()
      }
    }
    wait(for: [expectation], timeout: 1.0)
  }
  
  func testLoadAdditionalPages() {
    let expectation = self.expectation(description: "Load Page 2 for query `robin` ")
    moviesVC.query = "robin"
    moviesVC.loadMovies(page: 2) { (success) in
      if success {
        expectation.fulfill()
      } else {
        XCTFail()
      }
    }
    wait(for: [expectation], timeout: 1.0)
  }
  
  func testLoadMoviesPerformance() {
    // This is an example of a performance test case.
    moviesVC.query = "robin"
    self.measure {
      moviesVC.loadMovies { (success) in
        if success { XCTAssert(true) }
      }
    }
  }
  
}
