//
//  RemoteImageView.swift
//  FlingChallenge
//
//  Created by Alexander Kolov on 9/5/16.
//  Copyright © 2016 Alexander Kolov. All rights reserved.
//

import FlingChallengeKit
import UIKit

class RemoteImageView: UIImageView {

  static let operationQueue: NSOperationQueue = {
    let queue = NSOperationQueue()
    queue.maxConcurrentOperationCount = 3
    return queue
  }()

  var imageID: Int64? {
    didSet {
      if let imageID = imageID {
        let _operation = GetPostImageOperation(imageID: imageID)
        _operation.delegate = self
        operation = _operation

        RemoteImageView.operationQueue.addOperation(_operation)
      }
    }
  }

  private weak var operation: GetPostImageOperation?

  func cancelImageLoadingOperation() {
    operation?.cancel()
    operation?.delegate = nil
    operation = nil
    image = nil
    imageID = nil
  }

}

extension RemoteImageView: GetPostImageOperationDelegate {

  func getPostImageOperation(operation: GetPostImageOperation, didFinishWithImage image: UIImage) {
    self.image = image
  }

  func getPostImageOperation(operation: GetPostImageOperation, didFailWithError error: ErrorType) {
    print(error)
  }

}
