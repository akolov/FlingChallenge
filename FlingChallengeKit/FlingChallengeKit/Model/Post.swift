//
//  Post.swift
//  FlingChallengeKit
//
//  Created by Alexander Kolov on 5/8/16.
//  Copyright © 2016 Alexander Kolov. All rights reserved.
//

import Foundation
import CoreData

@objc(Post)
public class Post: _Post {

  static func createOrUpdate(managedObjectContext context: NSManagedObjectContext,
                             representation: [String: AnyObject]) throws -> Post? {
    let identifier: NSNumber = try representation.get("ID")
    let request = NSFetchRequest(entityName: self.entityName())
    request.predicate = NSPredicate(format: "identifier == %lld", identifier)
    var object = try context.executeFetchRequest(request).first as? Post
    if object == nil {
      object = Post(managedObjectContext: context)
      object?.identifier = identifier
    }

    if let object = object {
      object.imageID = try representation.get("ImageID")
      object.userID = try representation.get("UserID")
      object.userName = try representation.get("UserName")
      object.title = try representation.get("Title")
    }

    return object
  }

}
