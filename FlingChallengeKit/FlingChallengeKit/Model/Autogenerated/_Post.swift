// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Post.swift instead.

import Foundation
import CoreData

public enum PostAttributes: String {
    case identifier = "identifier"
    case imageID = "imageID"
    case title = "title"
    case userID = "userID"
    case userName = "userName"
}

public class _Post: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Post"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Post.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var identifier: Int64

    @NSManaged public
    var imageID: Int64

    @NSManaged public
    var title: String?

    @NSManaged public
    var userID: Int64

    @NSManaged public
    var userName: String

    // MARK: - Relationships

}

