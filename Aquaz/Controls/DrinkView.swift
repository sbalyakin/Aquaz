//
//  DrinkView.swift
//  Aquaz
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
  
  var isGroup: Bool = false {
    didSet {
      setNeedsDisplay()
    }
  }
  
  override func drawRect(rect: CGRect) {
    let minDimension = min(rect.width, rect.height)
    let drawRect = CGRect(x: rect.minX + trunc((rect.width - minDimension) / 2), y: rect.minY + trunc((rect.height - minDimension) / 2), width: minDimension, height: minDimension)
    drink.drawDrink(frame: drawRect)
    
    if highlighted {
      let path = UIBezierPath(ovalInRect: drawRect)
      UIColor(white: 0, alpha: 0.2).setFill()
      path.fill()
    }
    
    if isGroup {
      let dotRadius: CGFloat = 2
      let dotsCount = 3
      let dx = dotRadius * 3
      let y = drawRect.minY + dotRadius
      
      for i in 0..<dotsCount {
        let x = drawRect.maxX - CGFloat(i) * dx - dotRadius * 2
        
        let dotsRect = CGRect(x: x, y: y, width: dotRadius * 2, height: dotRadius * 2)
        let path = UIBezierPath(ovalInRect: dotsRect)
        drink.mainColor.setFill()
        path.fill()
      }
    }
  }

}
