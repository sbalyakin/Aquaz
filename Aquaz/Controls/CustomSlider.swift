//
//  CustomSlider.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 26.01.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

@IBDesignable class CustomSlider: UISlider {
  
  @IBInspectable var thumbRadius: CGFloat = 20 {
    didSet {
      if thumbRadius < 1 {
        thumbRadius = 1
      }
      baseInit()
      setNeedsDisplay()
    }
  }
  
  @IBInspectable var trackHeight: CGFloat = 18 {
    didSet {
      if trackHeight < 1 {
        trackHeight = 1
      }
      setNeedsDisplay()
    }
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    baseInit()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    baseInit()
  }
  
  private func baseInit() {
    if thumbRadius > 0 {
      let imageSize = calcThumbImageSize()
      let thumbRect = CGRect(origin: CGPoint.zeroPoint, size: imageSize)
      let thumbImage = StyleImages.imageOfThumb(frame: thumbRect)
      setThumbImage(thumbImage, forState: .Normal)
    }
  }
  
  private func calcThumbImageSize() -> CGSize {
    let originalWidth: CGFloat = 40
    let originalHeight: CGFloat = 40
    let frameWidth: CGFloat = 43
    let frameHeight: CGFloat = 49
    
    let imageWidth = thumbRadius * 2 * frameWidth / originalWidth
    let imageHeight = thumbRadius * 2 * frameHeight / originalHeight
    return CGSize(width: imageWidth, height: imageHeight)
  }
  
  override func trackRectForBounds(bounds: CGRect) -> CGRect {
    let standardRect = super.trackRectForBounds(bounds)
    let rect = CGRect(x: standardRect.minX, y: round(standardRect.midY - trackHeight / 2), width: standardRect.width, height: trackHeight)
    return rect
  }
  
  override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    
    thumbRadius = 15
    trackHeight = 14
  }
}

class StyleImages : NSObject {
  
  //// Drawing Methods
  
  class func drawThumb(#frame: CGRect) {
    //// General Declarations
    let context = UIGraphicsGetCurrentContext()
    
    //// Color Declarations
    let backgroundColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
    let strokeColor = UIColor(red: 0.816, green: 0.824, blue: 0.827, alpha: 1.000)
    let fillColor = UIColor(red: 0.902, green: 0.906, blue: 0.910, alpha: 1.000)
    let shadowColor2 = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
    
    //// Shadow Declarations
    let shadow = shadowColor2.colorWithAlphaComponent(0.18)
    let shadowOffset = CGSizeMake(0.1, 3.1)
    let shadowBlurRadius: CGFloat = 3
    
    
    //// Subframes
    let group4: CGRect = CGRectMake(frame.minX + floor(frame.width * 0.03488) + 0.5, frame.minY + floor(frame.height * 0.09184) + 0.5, floor(frame.width * 0.96512) - floor(frame.width * 0.03488), floor(frame.height * 0.90816) - floor(frame.height * 0.09184))
    
    
    //// Group 4
    //// Oval 5 Drawing
    var oval5Path = UIBezierPath(ovalInRect: CGRectMake(group4.minX + floor(group4.width * 0.00000 + 0.5), group4.minY + floor(group4.height * 0.00000 + 0.5), floor(group4.width * 1.00000 + 0.5) - floor(group4.width * 0.00000 + 0.5), floor(group4.height * 1.00000 + 0.5) - floor(group4.height * 0.00000 + 0.5)))
    CGContextSaveGState(context)
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, (shadow as UIColor).CGColor)
    backgroundColor.setFill()
    oval5Path.fill()
    CGContextRestoreGState(context)
    
    strokeColor.setStroke()
    oval5Path.lineWidth = 0.5
    oval5Path.stroke()
    
    
    //// Polygon Drawing
    var polygonPath = UIBezierPath()
    polygonPath.moveToPoint(CGPointMake(group4.minX + 0.19375 * group4.width, group4.minY + 0.50625 * group4.height))
    polygonPath.addLineToPoint(CGPointMake(group4.minX + 0.44219 * group4.width, group4.minY + 0.25727 * group4.height))
    polygonPath.addLineToPoint(CGPointMake(group4.minX + 0.44219 * group4.width, group4.minY + 0.75523 * group4.height))
    polygonPath.addLineToPoint(CGPointMake(group4.minX + 0.19375 * group4.width, group4.minY + 0.50625 * group4.height))
    polygonPath.closePath()
    fillColor.setFill()
    polygonPath.fill()
    strokeColor.setStroke()
    polygonPath.lineWidth = 0.5
    polygonPath.stroke()
    
    
    //// Polygon 2 Drawing
    var polygon2Path = UIBezierPath()
    polygon2Path.moveToPoint(CGPointMake(group4.minX + 0.80625 * group4.width, group4.minY + 0.50625 * group4.height))
    polygon2Path.addLineToPoint(CGPointMake(group4.minX + 0.55781 * group4.width, group4.minY + 0.25727 * group4.height))
    polygon2Path.addLineToPoint(CGPointMake(group4.minX + 0.55781 * group4.width, group4.minY + 0.75523 * group4.height))
    polygon2Path.addLineToPoint(CGPointMake(group4.minX + 0.80625 * group4.width, group4.minY + 0.50625 * group4.height))
    polygon2Path.closePath()
    fillColor.setFill()
    polygon2Path.fill()
    strokeColor.setStroke()
    polygon2Path.lineWidth = 0.5
    polygon2Path.stroke()
  }
  
  //// Generated Images
  
  class func imageOfThumb(#frame: CGRect) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
    StyleImages.drawThumb(frame: frame)
    
    let imageOfThumb = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    
    return imageOfThumb
  }
}