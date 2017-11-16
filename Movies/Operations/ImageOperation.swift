//
//  ImageOperation.swift
//  Movies
//
//  Created by Arvind Ravi on 16/11/17.
//  Copyright © 2017 Arvind Ravi. All rights reserved.
//

import UIKit

typealias ImageOperationCompletionHandlerType = ((UIImage) -> ())?

class ImageOperation: Operation {
  var url: URL
  var completionHandler: ImageOperationCompletionHandlerType
  var image: UIImage?
  
  init(url: URL) {
    self.url = url
  }
  
  override func main() {
    guard !isCancelled else { return }
    UIImage.fromURL(url) { [weak self] (image) in
      guard let strongSelf = self,
        !strongSelf.isCancelled,
        let image = image else { return }
      strongSelf.image = image
      strongSelf.completionHandler?(image)
    }
  }
}
