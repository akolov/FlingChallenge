//
//  DataControllerTests.swift
//  FlingChallengeKit
//
//  Created by Alexander Kolov on 5/8/16.
//  Copyright © 2016 Alexander Kolov. All rights reserved.
//

@testable import FlingChallengeKit
import XCTest

class DataControllerTests: XCTestCase {

  let queue = dispatch_queue_create("com.alexkolov.DataControllerTests", DISPATCH_QUEUE_CONCURRENT)

  func testDataControllerInitialization() {
    do {
      XCTAssertTrue(NSThread.isMainThread())

      let controller = try DataController()
      XCTAssertNotNil(controller)

      let mainContext = controller.managedObjectContext
      XCTAssertNotNil(mainContext)
      XCTAssertTrue(mainContext.concurrencyType == .MainQueueConcurrencyType)
    }
    catch {
      XCTFail()
    }
  }

  func testDataControllerThreadedInitialization() {
    let expectation = expectationWithDescription("Should create private managed object context")

    dispatch_async(queue) {
      XCTAssertFalse(NSThread.isMainThread())
      do {
        let anotherController = try DataController()
        let privateContext = anotherController.managedObjectContext
        XCTAssertNotNil(privateContext)
        XCTAssertTrue(privateContext.concurrencyType == .PrivateQueueConcurrencyType)
        expectation.fulfill()
      }
      catch {
        XCTFail()
      }
    }

    waitForExpectationsWithTimeout(5, handler: nil)
  }

}
