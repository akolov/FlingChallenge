//
//  GetPostImageOperation.swift
//  FlingChallengeKit
//
//  Created by Alexander Kolov on 5/9/16.
//  Copyright © 2016 Alexander Kolov. All rights reserved.
//

import Foundation

public protocol GetPostImageOperationDelegate: class {

  func getPostImageOperation(operation: GetPostImageOperation, didFinishWithImage image: UIImage)
  func getPostImageOperation(operation: GetPostImageOperation, didFailWithError error: ErrorType)

}

public final class GetPostImageOperation: Operation {

  public init(imageID: Int) {
    self.imageID = imageID
    super.init()
  }

  private(set) public var imageID: Int
  private(set) public var image: UIImage?

  public weak var delegate: GetPostImageOperationDelegate?

  private(set) public var error: ErrorType? {
    didSet {
      guard let error = error else {
        return
      }

      dispatch_async(dispatch_get_main_queue()) {
        self.delegate?.getPostImageOperation(self, didFailWithError: error)
      }
    }
  }

  public override var state: State {
    didSet {
      if let image = image where state == .Finished && error == nil {
        dispatch_async(dispatch_get_main_queue()) {
          self.delegate?.getPostImageOperation(self, didFinishWithImage: image)
        }
      }
    }
  }

  private var task: NSURLSessionTask?

  public override func start() {
    if !ready {
      return
    }

    state = .Executing

    guard !cancelled else {
      state = .Finished
      return
    }

    do {
      let imageURL = try Endpoints.Photos.URL(["id": String(self.imageID)])
      let cached = GetPostImageOperation.cache.objectForKey(imageURL.absoluteString)
      guard cached == nil else {
        image = cached as? UIImage
        return
      }

      let request = NSURLRequest(URL: imageURL)
      task = SessionManager.downloaderSession.downloadTaskWithRequest(request) { location, response, error in
        defer {
          self.state = .Finished
        }

        guard !self.cancelled else {
          return
        }

        guard error == nil else {
          self.error = error
          return
        }

        guard let response = response as? NSHTTPURLResponse where 200..<300 ~= response.statusCode else {
          self.error = FlingChallengeError.APIError(description: "Received non-200 HTTP response")
          return
        }

        guard let location = location else {
          self.error = FlingChallengeError.APIError(description: "Temporary file does not exist")
          return
        }

        guard let data = NSData(contentsOfURL: location) else {
          self.error = FlingChallengeError.APIError(description: "Received empty response")
          return
        }

        guard let downloaded = UIImage.fling_threadSafeImageWithData(data) else {
          self.error = FlingChallengeError.DeserializationError(description: "Could not decode image")
          return
        }

        downloaded.fling_inflate()
        self.image = downloaded

        GetPostImageOperation.cache.setObject(downloaded, forKey: imageURL.absoluteString, cost: data.length)
      }

      task?.resume()
    }
    catch {
      self.error = error
    }
  }

  public override func cancel() {
    task?.cancel()
    super.cancel()
  }

}

private extension GetPostImageOperation {

  private static let cache: NSCache = {
    let cache = NSCache()
    cache.totalCostLimit = 20 * 1024 * 1024
    return cache
  }()

}
