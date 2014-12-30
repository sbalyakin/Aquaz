//
//  DrinkCollectionViewCell.swift
//  Water Me
//
//  Created by Sergey Balyakin on 29.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class DrinkCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  
  override func layoutSubviews() {
    super.layoutSubviews()
    let minDimension = min(imageView.bounds.width, imageView.bounds.height)
    imageView.bounds.size = CGSizeMake(minDimension, minDimension)
  }
}
