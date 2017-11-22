//
//  Date+Util.swift
//  Movies
//
//  Created by Arvind Ravi on 22/11/17.
//  Copyright © 2017 Arvind Ravi. All rights reserved.
//

import Foundation

extension Date {
  static func from(string: String) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.date(from: string)
  }
}
