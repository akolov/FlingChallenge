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
  @IBOutlet weak var titleLabel: UILabel!

  override func prepareForReuse() {
    imageView.imageID = nil
    super.prepareForReuse()
  }

}
