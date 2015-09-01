//
//  DrinkCollectionViewCell.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 24.01.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class DrinkCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet weak var drinkView: DrinkView! {
    didSet {
      drinkView.backgroundColor = StyleKit.pageBackgroundColor
    }
  }
  
  @IBOutlet weak var drinkLabel: UILabel! {
    didSet {
      drinkLabel.backgroundColor = StyleKit.pageBackgroundColor
    }
  }
  
  override func drawRect(rect: CGRect) {
    drinkView.highlighted = highlighted
    super.drawRect(rect)
  }
  
}
