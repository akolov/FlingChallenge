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
    title = NSLocalizedString("My Feed", comment: "Feed view controller title")
    collectionView?.addSubview(refreshControl)
    refreshPosts()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
      switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
      case (.Compact, .Regular):
        layout.itemSize = CGSize(width: view.bounds.width, height: view.bounds.width)
        layout.sectionInset = UIEdgeInsetsZero
      default:
        let spacing = layout.minimumInteritemSpacing
        let width = (view.bounds.width - spacing * 3) / 2
        layout.itemSize = CGSize(width: width, height: width)
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
      }
    }
  }

  // MARK: Actions

  func refreshControlDidChangeValue(sender: UIRefreshControl) {
    refreshPosts()
  }

  // MARK: Outlets

  lazy var refreshControl: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self,
                             action: #selector(self.refreshControlDidChangeValue(_:)),
                             forControlEvents: .ValueChanged)
    return refreshControl
  }()

  // MARK: Internal methods

  func refreshPosts() {
    guard operationQueue.operationCount == 0 else {
      return
    }

    let operation = GetPostsOperation()
    operation.delegate = self
    operation.saveBatchSize = dataBatchSize
    operation.completionBlock = { [unowned self] in
      dispatch_async(dispatch_get_main_queue()) {
        self.refreshControl.endRefreshing()
      }
    }

    operationQueue.addOperation(operation)
    refreshControl.beginRefreshing()
  }

  // MARK: Properties

  let dataBatchSize = 20

  let operationQueue: NSOperationQueue = {
    let queue = NSOperationQueue()
    queue.qualityOfService = .UserInitiated
    queue.maxConcurrentOperationCount = 1
    return queue
  }()

  lazy var fetchedResultsController: NSFetchedResultsController? = {
    let fetchRequest = NSFetchRequest(entityName: Post.entityName())
    // In a better world API would have defined pagination and sorting
    // For now I'll sort by ascending identifier to provide better loading experience
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "identifier", ascending: true)]
    fetchRequest.fetchBatchSize = self.dataBatchSize

    do {
      let moc = try DataController().mainQueueManagedObjectContext
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
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PostCollectionViewCell",
                                                                     forIndexPath: indexPath) as! PostCollectionViewCell
    if let post = fetchedResultsController?.objectAtIndexPath(indexPath) as? Post {
      cell.titleLabel.text = post.title
      cell.authorLabel.text = String(format: NSLocalizedString("by %@", comment: "Author label title"), post.userName)
      cell.imageView.imageID = post.imageID
    }
    else {
      cell.titleLabel.text = nil
      cell.authorLabel.text = nil
      cell.imageView.imageID = nil
    }

    return cell
  }

}

extension PostsViewController: GetPostsOperationDelegate {

  func getPostsOperationDidFinish(operation: GetPostsOperation) {

  }

  func getPostsOperation(operation: GetPostsOperation, didFailWithError error: ErrorType) {
    print(error)
  }

}
