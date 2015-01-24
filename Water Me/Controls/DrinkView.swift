//
//  DrinkView.swift
//  Water Me
//
//  Created by Sergey Balyakin on 13.01.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class DrinkView: UIView {

  var drink: Drink! {
    didSet {
      setNeedsDisplay()
    }
  }
  
  var highlighted: Bool = false {
    didSet {
      setNeedsDisplay()
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func drawRect(rect: CGRect) {
    let minDimension = min(rect.width, rect.height)
    let drawRect = CGRectMake(rect.minX + trunc((rect.width - minDimension) / 2), rect.minY + trunc((rect.height - minDimension) / 2), minDimension, minDimension)
    drink.drawDrink(frame: drawRect)
    
    if highlighted {
      let path = UIBezierPath(ovalInRect: drawRect)
      UIColor(white: 0, alpha: 0.2).setFill()
      path.fill()
    }
  }

}
