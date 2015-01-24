//
//  NewDrinkCollectionViewCell.swift
//  Water Me
//
//  Created by Sergey Balyakin on 24.01.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class NewDrinkCollectionViewCell: UICollectionViewCell {

  @IBOutlet weak var drinkView: DrinkView!
  @IBOutlet weak var drinkLabel: UILabel!

  override func drawRect(rect: CGRect) {
    drinkView.highlighted = highlighted
    super.drawRect(rect)
  }

}
