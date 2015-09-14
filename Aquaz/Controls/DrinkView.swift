//
//  DrinkView.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 13.01.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

@IBDesignable
@objc(DrinkView)
class DrinkView: UIView {

  var drinkType: Drink.DrinkType! {
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
    #if TARGET_INTERFACE_BUILDER
      drawDrink(rect, drawFunction: StyleKit.drawWaterDrink, drinkColor: StyleKit.waterColor)
    #else
      if drinkType != nil {
        drawDrink(rect, drawFunction: drinkType.drawFunction, drinkColor: drinkType.mainColor)
      }
    #endif
  }

  private func drawDrink(rect: CGRect, drawFunction: Drink.DrawDrinkFunction, drinkColor: UIColor) {
    let minDimension = trunc(min(rect.width, rect.height))
    let drawRect = CGRect(x: trunc(rect.minX + (rect.width - minDimension) / 2), y: trunc(rect.minY + (rect.height - minDimension) / 2), width: minDimension, height: minDimension)
    
    drawFunction(frame: drawRect)
    
    if highlighted {
      let path = UIBezierPath(ovalInRect: drawRect)
      UIColor(white: 0, alpha: 0.2).setFill()
      path.fill()
    }
    
    if isGroup {
      let dotRadius: CGFloat = rect.width / 40
      let dotsCount = 3
      let dx = dotRadius * 3
      let y = drawRect.minY + dotRadius
      
      for i in 0..<dotsCount {
        let x = drawRect.maxX - CGFloat(i) * dx - dotRadius * 2
        
        let dotsRect = CGRect(x: x, y: y, width: dotRadius * 2, height: dotRadius * 2)
        let path = UIBezierPath(ovalInRect: dotsRect)
        drinkColor.setFill()
        path.fill()
      }
    }
  }

}
