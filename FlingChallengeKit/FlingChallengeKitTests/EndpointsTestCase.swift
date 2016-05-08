//
//  EndpointsTestCase.swift
//  FlingChallengeKit
//
//  Created by Alexander Kolov on 5/9/16.
//  Copyright © 2016 Alexander Kolov. All rights reserved.
//

@testable import FlingChallengeKit
import XCTest

class EndpointsTestCase: XCTestCase {

  func testBaseURL() {
    XCTAssertTrue(FlingChallengeKit.secure)
    var components = NSURLComponents(URL: FlingChallengeKit.baseURL, resolvingAgainstBaseURL: false)
    XCTAssertNotNil(components)
    XCTAssertEqual(components?.scheme, "https")

    FlingChallengeKit.secure = false
    components = NSURLComponents(URL: FlingChallengeKit.baseURL, resolvingAgainstBaseURL: false)
    XCTAssertNotNil(components)
    XCTAssertEqual(components?.scheme, "http")

    FlingChallengeKit.secure = true
    components = NSURLComponents(URL: FlingChallengeKit.baseURL, resolvingAgainstBaseURL: false)
    XCTAssertNotNil(components)
    XCTAssertEqual(components?.scheme, "https")
  }

  func testFeedURL() {
    do {
      let URL = try Endpoints.Feed.URL()
      XCTAssertNotNil(URL)
    }
    catch {
      XCTFail()
    }
  }

  func testPhotosURL() {
    do {
      let photoID = "5"
      let components = NSURLComponents(URL: try Endpoints.Photos.URL(["id": photoID]), resolvingAgainstBaseURL: false)
      XCTAssertNotNil(components)
      XCTAssertNotNil(components?.path)
      XCTAssertEqual((components!.path! as NSString).lastPathComponent, photoID)
    }
    catch {
      XCTFail()
    }
  }

}
