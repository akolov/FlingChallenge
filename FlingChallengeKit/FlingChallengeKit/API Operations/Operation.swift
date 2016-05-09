//
//  Operation.swift
//  FlingChallengeKit
//
//  Created by Alexander Kolov on 5/8/16.
//  Copyright © 2016 Alexander Kolov. All rights reserved.
//

import Foundation

public class Operation: NSOperation {

  public enum State: String {
    case Ready = "isReady"
    case Executing = "isExecuting"
    case Finished = "isFinished"
  }

  public override init() {
    state = .Ready
  }

  public var state: State {
    willSet {
      willChangeValueForKey(state.rawValue)
      willChangeValueForKey(newValue.rawValue)
    }
    didSet {
      didChangeValueForKey(oldValue.rawValue)
      didChangeValueForKey(state.rawValue)
    }
  }

  public override var ready: Bool {
    return super.ready && state == .Ready
  }

  public override var executing: Bool {
    return state == .Executing
  }

  public override var finished: Bool {
    return state == .Finished
  }

  public override var asynchronous: Bool {
    return true
  }

  public override func cancel() {
    if state == .Executing {
      state = .Finished
    }

    super.cancel()
  }

}
