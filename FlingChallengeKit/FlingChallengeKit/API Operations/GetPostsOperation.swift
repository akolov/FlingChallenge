//
//  GetPostsOperation.swift
//  FlingChallengeKit
//
//  Created by Alexander Kolov on 5/8/16.
//  Copyright © 2016 Alexander Kolov. All rights reserved.
//

import Foundation

public protocol GetPostsOperationDelegate: class {

  func getPostsOperationDidFinish(operation: GetPostsOperation)
  func getPostsOperation(operation: GetPostsOperation, didFailWithError error: ErrorType)

}

public final class GetPostsOperation: Operation {

  public weak var delegate: GetPostsOperationDelegate?
  public var saveBatchSize = 20

  private(set) public var error: ErrorType? {
    didSet {
      guard let error = error else {
        return
      }

      dispatch_async(dispatch_get_main_queue()) {
        self.delegate?.getPostsOperation(self, didFailWithError: error)
      }
    }
  }

  public override var state: State {
    didSet {
      if state == .Finished && error == nil {
        dispatch_async(dispatch_get_main_queue()) {
          self.delegate?.getPostsOperationDidFinish(self)
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
      let request = NSURLRequest(URL: try Endpoints.Feed.URL())
      task = SessionManager.apiSession.dataTaskWithRequest(request) { data, response, error in
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

        guard let data = data else {
          self.error = FlingChallengeError.APIError(description: "Received empty response")
          return
        }

        do {
          let json = try NSJSONSerialization.JSONObjectWithData(data, options: [])
          guard let list = json as? [[String: AnyObject]] else {
            self.error = FlingChallengeError.DeserializationError(description: "Expected list of posts, " +
                                                                               "but got \(json)")
            return
          }

          try DataController().withPrivateContext { context in
            var counter = 0
            for object in list {
              guard !self.cancelled else {
                break
              }

              _ = try Post.createOrUpdate(managedObjectContext: context, representation: object)

              if counter % self.saveBatchSize == 0 {
                if context.hasChanges {
                  try context.save()

                  if let parentContext = context.parentContext {
                    try parentContext.performBlockAndWaitThrowable {
                      if parentContext.hasChanges {
                        try parentContext.save()
                      }
                    }
                  }
                }
              }

              counter += 1
            }
          }
        }
        catch {
          self.error = error
          return
        }
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
