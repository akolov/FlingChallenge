//
//  PostTests.swift
//  FlingChallengeKit
//
//  Created by Alexander Kolov on 5/9/16.
//  Copyright © 2016 Alexander Kolov. All rights reserved.
//

@testable import FlingChallengeKit
import CoreData
import XCTest

class PostTests: XCTestCase {

  override class func setUp() {
    super.setUp()
    FlingChallengeKit.strictSSL = false
    _ = try? DataController().destroyPersistentStore()
  }

  override func tearDown() {
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
      XCTAssertEqual(post.identifier, try object.get("ID"))
      XCTAssertEqual(post.imageID, try object.get("ImageID"))
      XCTAssertEqual(post.title, object["Title"])
      XCTAssertEqual(post.userID, try object.get("UserID"))
      XCTAssertEqual(post.userName, object["UserName"])
    }
    catch {
      XCTFail()
    }
  }

  func testPostDownload() {
    let queue = NSOperationQueue()
    queue.qualityOfService = .UserInitiated

    let expectation = expectationWithDescription("GetPostsOperation has completed")

    let operation = GetPostsOperation()
    operation.completionBlock = { [unowned operation] in
      XCTAssertNil(operation.error)
      expectation.fulfill()
    }

    queue.addOperation(operation)

    waitForExpectationsWithTimeout(10, handler: nil)

    do {
      let fetchRequest = NSFetchRequest(entityName: Post.entityName())
      let count = try DataController().managedObjectContext.countForFetchRequest(fetchRequest, error: nil)

      if count == NSNotFound {
        XCTFail()
      }

      if count == 0 {
        XCTFail()
      }
    }
    catch {
      XCTFail()
    }
  }

}
