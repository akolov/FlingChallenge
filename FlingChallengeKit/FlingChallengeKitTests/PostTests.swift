//
//  PostTests.swift
//  FlingChallengeKit
//
//  Created by Alexander Kolov on 5/9/16.
//  Copyright © 2016 Alexander Kolov. All rights reserved.
//

@testable import FlingChallengeKit
import XCTest

class PostTests: XCTestCase {

  override class func setUp() {
    super.setUp()
    _ = try? DataController().destroyPersistentStore()
  }

  override class func tearDown() {
    _ = try? DataController().destroyPersistentStore()
    super.tearDown()
  }

  func testPostDeserialization() {
    let object = [
      "ID": 46,
      "ImageID": 255,
      "Title": "Chigwell, Epping Forest",
      "UserID": 4,
      "UserName": "Harry"
    ]

    do {
      let controller = try DataController()
      var post: Post!
      try controller.withManagedObjectContext { context in
        post = try Post(managedObjectContext: context, representation: object)
      }

      XCTAssertNotNil(post)
      XCTAssertNotNil(post.objectID.persistentStore)
      XCTAssertFalse(post.objectID.temporaryID)
      XCTAssertEqual(post.identifier, object["ID"])
      XCTAssertEqual(post.imageID, object["ImageID"])
      XCTAssertEqual(post.title, object["Title"])
      XCTAssertEqual(post.userID, object["UserID"])
      XCTAssertEqual(post.userName, object["UserName"])
    }
    catch {
      XCTFail()
    }
  }

}
