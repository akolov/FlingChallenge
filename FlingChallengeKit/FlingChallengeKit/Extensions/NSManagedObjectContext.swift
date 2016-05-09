//
//  NSManagedObjectContext.swift
//  FlingChallengeKit
//
//  Created by Alexander Kolov on 9/5/16.
//  Copyright © 2016 Alexander Kolov. All rights reserved.
//

import CoreData
import Foundation

extension NSManagedObjectContext {

  public func performBlockAndWaitThrowable(block: () throws -> Void) throws {
    var _error: ErrorType?
    performBlockAndWait {
      do {
        try block()
      }
      catch {
        _error = error
      }
    }

    if let _error = _error {
      throw _error
    }
  }

}
