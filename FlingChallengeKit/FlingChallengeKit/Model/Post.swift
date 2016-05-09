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
                             representation: [String: AnyObject]) throws {
    let identifier = (try representation.get("ID") as NSNumber).longLongValue
    let request = NSFetchRequest(entityName: self.entityName())
    request.predicate = NSPredicate(format: "identifier == %lld", identifier)
    var object = try context.executeFetchRequest(request).first as? Post
    if object == nil {
      object = Post(managedObjectContext: context)
    }

    if let object = object {
      object.imageID = (try representation.get("ImageID") as NSNumber).longLongValue
      object.userID = (try representation.get("UserID") as NSNumber).longLongValue
      object.userName = try representation.get("UserName")
      object.title = try representation.get("Title")
    }
  }

}
