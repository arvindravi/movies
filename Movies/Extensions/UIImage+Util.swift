//
//  UIImage+Util.swift
//  Movies
//
//  Created by Arvind Ravi on 16/11/17.
//  Copyright © 2017 Arvind Ravi. All rights reserved.
//

import UIKit

typealias UIImageDownloadCompletionHandler = (UIImage?) -> ()
extension UIImage {
  static func fromURL(_ url: URL, completion: @escaping UIImageDownloadCompletionHandler) {
    let session = URLSession.shared
    let task = session.dataTask(with: url) { (data, response, error) in
      guard let httpResponse = response as? HTTPURLResponse,
        httpResponse.statusCode  == 200,
        let data = data else {
          completion(nil)
          return
      }
      
      guard let image = UIImage(data: data) else {
        completion(nil)
        return
      }
      
      completion(image)
    }
    
    task.resume()
  }
}
