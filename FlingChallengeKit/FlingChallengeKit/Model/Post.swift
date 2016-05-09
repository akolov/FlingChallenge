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

  convenience init?(managedObjectContext: NSManagedObjectContext, representation: [String: AnyObject]) throws {
    self.init(managedObjectContext: managedObjectContext)
    identifier = (try representation.get("ID") as NSNumber).longLongValue
    imageID = (try representation.get("ImageID") as NSNumber).longLongValue
    userID = (try representation.get("UserID") as NSNumber).longLongValue
    userName = try representation.get("UserName")
    title = try representation.get("Title")
  }

}
