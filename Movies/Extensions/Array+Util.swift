//
//  Array+Util.swift
//  Movies
//
//  Created by Arvind Ravi on 19/11/17.
//  Copyright © 2017 Arvind Ravi. All rights reserved.
//

import Foundation

extension Array {
  mutating func shiftRight() {
    if let obj = self.popLast(){
      self.insert(obj, at: 0)
    }
  }
}
