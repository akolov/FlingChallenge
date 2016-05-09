//
//  Dictionary.swift
//  FlingChallengeKit
//
//  Created by Alexander Kolov on 5/9/16.
//  Copyright © 2016 Alexander Kolov. All rights reserved.
//

import Foundation

extension Dictionary where Key: StringLiteralConvertible {

  func get<T>(key: Key) throws -> T {
    guard let fetched = self[key] else {
      throw FlingChallengeError.DeserializationError(description: "The key \(key) was not found.")
    }

    guard let typed = fetched as? T else {
      throw FlingChallengeError.DeserializationError(description: "Value for key \(key) has invalid type: \(fetched).")
    }

    return typed
  }

  func get<T: NilLiteralConvertible>(key: Key) throws -> T {
    guard let fetched = self[key] as? T else {
      return nil
    }
    return fetched
  }

  func get<T, U>(key: Key, @noescape transformation: T throws -> U?) throws -> U {
    let fetched: T = try self.get(key)
    guard let transformed = try transformation(fetched) else {
      throw FlingChallengeError.DeserializationError(description: "Transformation for key \(key) has failed.")
    }
    return transformed
  }

  func get<T, U>(key: Key, @noescape transformation: T throws -> U?) throws -> U? {
    guard let fetched = self[key] as? T else { return nil }
    return try transformation(fetched)
  }

}
