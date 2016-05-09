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
    identifier = try representation.get("ID")
    imageID = try representation.get("ImageID")
    userID = try representation.get("UserID")
    userName = try representation.get("UserName")
    title = try representation.get("Title")
  }

}
