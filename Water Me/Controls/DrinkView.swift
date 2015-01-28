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
  
  var isGroup: Bool = false {
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
    let drawRect = CGRect(x: rect.minX + trunc((rect.width - minDimension) / 2), y: rect.minY + trunc((rect.height - minDimension) / 2), width: minDimension, height: minDimension)
    drink.drawDrink(frame: drawRect)
    
    if highlighted {
      let path = UIBezierPath(ovalInRect: drawRect)
      UIColor(white: 0, alpha: 0.2).setFill()
      path.fill()
    }
    
    if isGroup {
      let dotRadius: CGFloat = 2
      
      var markRect = drawRect
      markRect.size.width /= 5
      markRect.size.height /= 5
      markRect.offset(dx: drawRect.width - markRect.width, dy: 0)
      markRect.inset(dx: dotRadius, dy: dotRadius)

      var dotsCount = 3
      var dx = markRect.width / CGFloat(dotsCount)
      for i in 0..<dotsCount {
        let x = markRect.minX + CGFloat(i) * dx
        
        let dotsRect = CGRect(x: x - dotRadius, y: markRect.minY - dotRadius, width: dotRadius * 2, height: dotRadius * 2)
        let path = UIBezierPath(ovalInRect: dotsRect)
        drink.mainColor.setFill()
        path.fill()
      }
    }
  }

}
