//
//  DrinkView.swift
//  Water Me
//
//  Created by Sergey Balyakin on 13.01.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class DrinkView: UIView {

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  var drink: Drink!
  
  override func drawRect(rect: CGRect) {
    let minDimension = min(rect.width, rect.height)
    let drawRect = CGRectMake(rect.minX + trunc((rect.width - minDimension) / 2), rect.minY + trunc((rect.height - minDimension) / 2), minDimension, minDimension)
    drink.drawDrink(frame: drawRect)
  }

}
