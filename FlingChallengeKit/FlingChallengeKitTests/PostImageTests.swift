//
//  PostImageTests.swift
//  FlingChallengeKit
//
//  Created by Alexander Kolov on 5/9/16.
//  Copyright © 2016 Alexander Kolov. All rights reserved.
//

@testable import FlingChallengeKit
import XCTest

class PostImageTests: XCTestCase {

  override class func setUp() {
    super.setUp()
    FlingChallengeKit.strictSSL = false
  }

  func testPostDownload() {
    let queue = NSOperationQueue()
    queue.qualityOfService = .UserInitiated

    let expectation = expectationWithDescription("GetPostImageOperation has completed")

    let operation = GetPostImageOperation(imageID: 300)
    operation.completionBlock = { [unowned operation] in
      XCTAssertNil(operation.error)
      XCTAssertNotNil(operation.image)
      expectation.fulfill()
    }

    queue.addOperation(operation)
    waitForExpectationsWithTimeout(10, handler: nil)
  }

}
