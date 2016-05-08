//
//  DispatchTests.swift
//  FlingChallengeKit
//
//  Created by Alexander Kolov on 5/8/16.
//  Copyright © 2016 Alexander Kolov. All rights reserved.
//

@testable import FlingChallengeKit
import XCTest

class DispatchTests: XCTestCase {

  struct DispatchTestError: ErrorType { }

  let queue = dispatch_queue_create("com.alexkolov.FlingChallengeKitTests", DISPATCH_QUEUE_CONCURRENT)

  func testDispatchOnceThrows() {
    struct Static {
      static var firstToken: dispatch_once_t = 0
      static var secondToken: dispatch_once_t = 0
    }

    var counter: Int = 0

    do {
      for _ in 0..<100 {
        try dispatch_once_throws(&Static.firstToken) {
          counter += 1
        }
      }
    }
    catch {
      XCTFail()
    }

    XCTAssertEqual(counter, 1)

    do {
      try dispatch_once_throws(&Static.secondToken) {
        throw DispatchTestError()
      }

      XCTFail()
    }
    catch {
      XCTAssertTrue(error is DispatchTestError)
    }
  }

  func testDispatchSyncThrows() {
    let expectationPass = expectationWithDescription("dispatch_sync_throws should pass")
    do {
      try dispatch_sync_throws(queue) {
        expectationPass.fulfill()
      }
    }
    catch {
      XCTFail()
    }

    let expectationThrow = expectationWithDescription("dispatch_sync_throws should throw")
    do {
      try dispatch_sync_throws(queue) {
        throw DispatchTestError()
      }

      XCTFail()
    }
    catch {
      XCTAssertTrue(error is DispatchTestError)
      expectationThrow.fulfill()
    }

    waitForExpectationsWithTimeout(5, handler: nil)
  }

  func testDispatchSyncMain() {
    do {
      try dispatch_sync_main {
        XCTAssertTrue(NSThread.isMainThread())
      }
    }
    catch {
      XCTFail()
    }

    let expectationPass = expectationWithDescription("dispatch_sync_main should pass")
    let expectationThrow = expectationWithDescription("dispatch_sync_main should throw")

    dispatch_async(queue) {
      do {
        try dispatch_sync_main {
          XCTAssertTrue(NSThread.isMainThread())
          expectationPass.fulfill()
        }
      }
      catch {
        XCTFail()
      }

      do {
        try dispatch_sync_main {
          throw DispatchTestError()
        }
      }
      catch {
        XCTAssertTrue(error is DispatchTestError)
        expectationThrow.fulfill()
      }
    }

    waitForExpectationsWithTimeout(5, handler: nil)
  }

}
