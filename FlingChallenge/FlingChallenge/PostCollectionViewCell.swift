//
//  PostCollectionViewCell.swift
//  FlingChallenge
//
//  Created by Alexander Kolov on 9/5/16.
//  Copyright © 2016 Alexander Kolov. All rights reserved.
//

import UIKit

class PostCollectionViewCell: UICollectionViewCell {

  @IBOutlet weak var imageView: RemoteImageView!

  @IBOutlet weak var titleLabel: UILabel! {
    didSet {
      titleLabel.layer.shadowOffset = CGSize(width: 1, height: 1)
      titleLabel.layer.shadowColor = UIColor.blackColor().CGColor
      titleLabel.layer.shadowOpacity = 0.6
      titleLabel.layer.shadowRadius = 1
    }
  }

  @IBOutlet weak var authorLabel: UILabel!

  @IBOutlet weak var bottomSeparatorHeightConstraint: NSLayoutConstraint! {
    didSet {
      bottomSeparatorHeightConstraint.constant = 0.5
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    contentView.layoutMargins = UIEdgeInsetsZero
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    imageView.imageID = nil
  }

}
