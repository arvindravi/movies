//
//  UIView+Util.swift
//  Movies
//
//  Created by Arvind Ravi on 21/11/17.
//  Copyright © 2017 Arvind Ravi. All rights reserved.
//

import UIKit

extension UIView {
  func pin(to superview: UIView) {
    if #available(iOS 11, *) {
      NSLayoutConstraint.activate([
        self.leftAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leftAnchor),
        self.rightAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.rightAnchor),
        self.topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor),
        self.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor)
      ])
    } else {
      NSLayoutConstraint.activate([
        self.leftAnchor.constraint(equalTo: superview.leftAnchor),
        self.rightAnchor.constraint(equalTo: superview.rightAnchor),
        self.topAnchor.constraint(equalTo: superview.topAnchor),
        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
      ])
    }
  }
}
