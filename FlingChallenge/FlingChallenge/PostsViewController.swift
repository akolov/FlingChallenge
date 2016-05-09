//
//  PostsViewController.swift
//  FlingChallenge
//
//  Created by Alexander Kolov on 5/8/16.
//  Copyright © 2016 Alexander Kolov. All rights reserved.
//

import CoreData
import FlingChallengeKit
import UIKit

class PostsViewController: UICollectionViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    refreshPosts()
  }

  // MARK: Internal methods

  func refreshPosts() {
    guard operationQueue.operationCount == 0 else {
      return
    }

    let operation = GetPostsOperation()
    operationQueue.addOperation(operation)
  }

  // MARK: Properties

  let operationQueue: NSOperationQueue = {
    let queue = NSOperationQueue()
    queue.qualityOfService = .UserInitiated
    queue.maxConcurrentOperationCount = 1
    return queue
  }()

  lazy var fetchedResultsController: NSFetchedResultsController? = {
    let fetchRequest = NSFetchRequest(entityName: Post.entityName())
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "identifier", ascending: false)]
    fetchRequest.fetchBatchSize = 20

    do {
      let dataController = try DataController()
      let moc = dataController.managedObjectContext
      let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                           managedObjectContext: moc,
                                           sectionNameKeyPath: nil,
                                           cacheName: nil)
      frc.delegate = self
      try frc.performFetch()
      return frc
    }
    catch {
      Alerts.presentFatalAlert(self)
    }

    return nil
  }()


}

// MARK: NSFetchedResultsControllerDelegate

extension PostsViewController: NSFetchedResultsControllerDelegate {

  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    collectionView?.reloadData()
  }

}

// MARK: UICollectionViewDataSource

extension PostsViewController {

  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return fetchedResultsController?.sections?.count ?? 0
  }

  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
  }

  override func collectionView(collectionView: UICollectionView,
                               cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PostCollectionViewCell", forIndexPath: indexPath)
    return cell
  }

}
