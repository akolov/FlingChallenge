//
//  DataController.swift
//  FlingChallengeKit
//
//  Created by Alexander Kolov on 5/8/16.
//  Copyright © 2016 Alexander Kolov. All rights reserved.
//

import Foundation
import CoreData

final public class DataController {

  public init() throws {
    struct Static {
      static var onceToken: dispatch_once_t = 0
    }

    try dispatch_once_throws(&Static.onceToken) {
      try dispatch_sync_main {
        try DataController.initializeCoreDataStack()
      }
    }
  }

  public static let applicationDocumentsDirectory: NSURL = {
    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    return urls[urls.count - 1]
  }()

  public lazy var mainQueueManagedObjectContext: NSManagedObjectContext = {
    return DataController._mainQueueManagedObjectContext
  }()

  public lazy var privateManagedObjectContext: NSManagedObjectContext = {
    return DataController._privateQueueManagedObjectContext
  }()

  public func withPrivateContext(closure: (NSManagedObjectContext) throws -> Void) throws {
    try privateManagedObjectContext.performBlockAndWaitThrowable {
      try closure(self.privateManagedObjectContext)
      if self.privateManagedObjectContext.hasChanges {
        try self.privateManagedObjectContext.save()
      }
    }

    try self.mainQueueManagedObjectContext.performBlockAndWaitThrowable {
      if self.mainQueueManagedObjectContext.hasChanges {
        try self.mainQueueManagedObjectContext.save()
      }
    }
  }

  public func destroyPersistentStore() throws {
    try DataController.persistentStoreCoordinator?.destroyPersistentStoreAtURL(
      DataController.persistentStoreURL,
      withType: NSSQLiteStoreType,
      options: DataController.persistentStoreOptions
    )

    try DataController.persistentStoreCoordinator?.addPersistentStoreWithType(
      NSSQLiteStoreType,
      configuration: nil,
      URL: DataController.persistentStoreURL,
      options: DataController.persistentStoreOptions
    )
  }

}

// MARK: Private

private extension DataController {

  private static func initializeCoreDataStack() throws {
    assert(NSThread.isMainThread(), "\(#function) must be executed on main thread")

    guard let bundle = NSBundle(identifier: "com.alexkolov.FlingChallengeKit") else {
      throw FlingChallengeError.InitializationError(description: "Could not find framework bundle")
    }

    guard let modelURL = bundle.URLForResource("Fling", withExtension: "momd") else {
      throw FlingChallengeError.InitializationError(description: "Could not find model in main bundle")
    }

    guard let model = NSManagedObjectModel(contentsOfURL: modelURL) else {
      throw FlingChallengeError.InitializationError(description: "Could not load model from URL: \(modelURL)")
    }

    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
    try coordinator.addPersistentStoreWithType(NSSQLiteStoreType,
                                               configuration: nil,
                                               URL: persistentStoreURL,
                                               options: persistentStoreOptions)
    persistentStoreCoordinator = coordinator

    let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    context.persistentStoreCoordinator = coordinator
    _mainQueueManagedObjectContext = context

    let privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
    privateContext.parentContext = _mainQueueManagedObjectContext
    privateContext.mergePolicy = NSMergePolicy(mergeType: .MergeByPropertyObjectTrumpMergePolicyType)
    _privateQueueManagedObjectContext = privateContext
  }

  private static let persistentStoreURL: NSURL = {
    return DataController.applicationDocumentsDirectory.URLByAppendingPathComponent(persistentStoreName)
  }()

  private static let persistentStoreOptions = [
    NSMigratePersistentStoresAutomaticallyOption: true,
    NSInferMappingModelAutomaticallyOption: true
  ]

  private static let persistentStoreName = "FlingChallenge.sqlite"
  private static var managedObjectModel: NSManagedObjectModel?
  private static var persistentStoreCoordinator: NSPersistentStoreCoordinator?
  private static var _mainQueueManagedObjectContext: NSManagedObjectContext!
  private static var _privateQueueManagedObjectContext: NSManagedObjectContext!

}
