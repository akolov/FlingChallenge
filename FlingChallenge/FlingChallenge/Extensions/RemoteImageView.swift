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

  override init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initialize()
  }

  private func initialize() {
    self.addSubview(progressIndicator)
    progressIndicator.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
    progressIndicator.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
  }

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

  override var image: UIImage? {
    didSet {
      progressIndicator.hidden = image != nil
    }
  }

  private(set) lazy var progressIndicator: CircularProgressIndicator = {
    let progressIndicator = CircularProgressIndicator()
    progressIndicator.translatesAutoresizingMaskIntoConstraints = false
    return progressIndicator
  }()

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

  func getPostImageOperation(operation: GetPostImageOperation, didUpdateProgress progress: Float) {
    progressIndicator.progress = progress
  }

  func getPostImageOperation(operation: GetPostImageOperation, didFinishWithImage image: UIImage) {
    self.image = image
  }

  func getPostImageOperation(operation: GetPostImageOperation, didFailWithError error: ErrorType) {
    print(error)
  }

}
