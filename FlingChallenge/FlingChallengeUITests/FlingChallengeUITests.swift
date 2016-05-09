//
//  FlingChallengeUITests.swift
//  FlingChallengeUITests
//
//  Created by Alexander Kolov on 5/8/16.
//  Copyright © 2016 Alexander Kolov. All rights reserved.
//

import XCTest

class FlingChallengeUITests: XCTestCase {

  override func setUp() {
    super.setUp()
    continueAfterFailure = false
    XCUIApplication().launch()
  }

  func testShowsContent() {
    let app = XCUIApplication()
    let collectionView = app.collectionViews
    XCTAssert(collectionView.cells.count > 0)
  }

}
