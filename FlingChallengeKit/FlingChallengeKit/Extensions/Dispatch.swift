//
//  Dispatch.swift
//  FlingChallengeKit
//
//  Created by Alexander Kolov on 5/8/16.
//  Copyright © 2016 Alexander Kolov. All rights reserved.
//

import Foundation

public typealias dispatch_throwable = () throws -> Void

public func dispatch_sync_main(closure: dispatch_throwable) throws {
  if NSThread.isMainThread() {
    try closure()
  }
  else {
    try dispatch_sync_throws(dispatch_get_main_queue(), closure)
  }
}

public func dispatch_sync_throws(queue: dispatch_queue_t, _ closure: dispatch_throwable) throws {
  var _error: ErrorType?
  dispatch_sync(queue) {
    do {
      try closure()
    }
    catch {
      _error = error
    }
  }

  if let _error = _error {
    throw _error
  }
}

public func dispatch_once_throws(predicate: UnsafeMutablePointer<dispatch_once_t>,
                                 _ closure: dispatch_throwable) throws {
  var _error: ErrorType?
  dispatch_once(predicate) {
    do {
      try closure()
    }
    catch {
      _error = error
    }
  }

  if let _error = _error {
    throw _error
  }
}
