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

  public init(imageID: Int64) {
    self.imageID = imageID
    super.init()
  }

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
      task = self.session.downloadTaskWithRequest(request)
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

  // MARK: Public

  private(set) public var imageID: Int64
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

  // MARK: Private

  private static let downloaderCache = NSURLCache(memoryCapacity: 0,
                                                  diskCapacity: 100 * 1024 * 1024,
                                                  diskPath: "downloads")

  private lazy var session: NSURLSession = {
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    configuration.URLCache = GetPostImageOperation.downloaderCache
    let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    return session
  }()

  private var task: NSURLSessionTask?

}

private extension GetPostImageOperation {

  private static let cache: NSCache = {
    let cache = NSCache()
    cache.totalCostLimit = 20 * 1024 * 1024
    return cache
  }()

}

extension GetPostImageOperation: NSURLSessionDelegate {

  public func URLSession(session: NSURLSession,
                         didReceiveChallenge challenge: NSURLAuthenticationChallenge,
                         completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
    guard !FlingChallengeKit.strictSSL else {
      completionHandler(.PerformDefaultHandling, nil)
      return
    }

    guard let trust = challenge.protectionSpace.serverTrust
      where challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust &&
        challenge.protectionSpace.host == FlingChallengeKit.apiHost else {
          completionHandler(.PerformDefaultHandling, nil)
          return
    }

    let credential = NSURLCredential(forTrust: trust)
    completionHandler(.UseCredential, credential)
  }

  public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
    defer {
      self.state = .Finished
    }

    guard error == nil else {
      self.error = error
      return
    }

    guard let response = task.response as? NSHTTPURLResponse where 200..<300 ~= response.statusCode else {
      self.error = FlingChallengeError.APIError(description: "Received non-200 HTTP response")
      return
    }
  }

}

extension GetPostImageOperation: NSURLSessionDownloadDelegate {

  public func URLSession(session: NSURLSession,
                  downloadTask: NSURLSessionDownloadTask,
                  didWriteData bytesWritten: Int64,
                  totalBytesWritten: Int64,
                  totalBytesExpectedToWrite: Int64) {

  }

  public func URLSession(session: NSURLSession,
                         downloadTask: NSURLSessionDownloadTask,
                         didFinishDownloadingToURL location: NSURL) {
    guard !self.cancelled else {
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

    if let imageURL = task?.originalRequest?.URL?.absoluteString {
      GetPostImageOperation.cache.setObject(downloaded, forKey: imageURL, cost: data.length)
    }
  }

}
