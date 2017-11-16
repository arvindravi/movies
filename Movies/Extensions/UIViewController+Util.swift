//
//  UIViewController+Util.swift
//  Movies
//
//  Created by Arvind Ravi on 16/11/17.
//  Copyright © 2017 Arvind Ravi. All rights reserved.
//

import UIKit

extension UIViewController {
  func showAlert(_ title: String, message: String) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(OKAction)
    present(alertController, animated: true, completion: nil)
  }
}
