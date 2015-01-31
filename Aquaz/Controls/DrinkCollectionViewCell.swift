//
//  DrinkCollectionViewCell.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 24.01.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class DrinkCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet weak var drinkView: DrinkView!
  @IBOutlet weak var drinkLabel: UILabel!
  
  override func drawRect(rect: CGRect) {
    drinkView.highlighted = highlighted
    
    if highlighted {
      drinkLabel.textColor = UIColor.blackColor()
    } else {
      drinkLabel.textColor = UIColor.lightGrayColor()
    }
    
    super.drawRect(rect)
  }
  
}
