//
//  CustomSlider.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 26.01.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
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
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    baseInit()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    baseInit()
  }
  
  fileprivate func baseInit() {
    if thumbRadius > 0 {
      let imageSize = calcThumbImageSize()
      let thumbRect = CGRect(origin: CGPoint.zero, size: imageSize)
      let thumbImage = StyleImages.imageOfThumb(frame: thumbRect)
      setThumbImage(thumbImage, for: UIControl.State())
    }
  }
  
  fileprivate func calcThumbImageSize() -> CGSize {
    let originalWidth: CGFloat = 40
    let originalHeight: CGFloat = 40
    let frameWidth: CGFloat = 43
    let frameHeight: CGFloat = 49
    
    let imageWidth = thumbRadius * 2 * frameWidth / originalWidth
    let imageHeight = thumbRadius * 2 * frameHeight / originalHeight
    return CGSize(width: imageWidth, height: imageHeight)
  }
  
  override func trackRect(forBounds bounds: CGRect) -> CGRect {
    let standardRect = super.trackRect(forBounds: bounds)
    let rect = CGRect(x: standardRect.minX, y: round(standardRect.midY - trackHeight / 2), width: standardRect.width, height: trackHeight)
    return rect
  }
  
  @available(iOS 8.0, *)
  override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    
    thumbRadius = 15
    trackHeight = 14
  }
}

class StyleImages : NSObject {
  
  //// Drawing Methods
  
  class func drawThumb(frame: CGRect) {
    //// General Declarations
    let context = UIGraphicsGetCurrentContext()
    
    //// Color Declarations
    let backgroundColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
    let strokeColor = UIColor(red: 0.816, green: 0.824, blue: 0.827, alpha: 1.000)
    let fillColor = UIColor(red: 0.902, green: 0.906, blue: 0.910, alpha: 1.000)
    let shadowColor2 = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
    
    //// Shadow Declarations
    let shadow = shadowColor2.withAlphaComponent(0.18)
    let shadowOffset = CGSize(width: 0.1, height: 3.1)
    let shadowBlurRadius: CGFloat = 3
    
    
    //// Subframes
    let group4: CGRect = CGRect(x: frame.minX + floor(frame.width * 0.03488) + 0.5, y: frame.minY + floor(frame.height * 0.09184) + 0.5, width: floor(frame.width * 0.96512) - floor(frame.width * 0.03488), height: floor(frame.height * 0.90816) - floor(frame.height * 0.09184))
    
    
    //// Group 4
    //// Oval 5 Drawing
    let oval5Path = UIBezierPath(ovalIn: CGRect(x: group4.minX + floor(group4.width * 0.00000 + 0.5), y: group4.minY + floor(group4.height * 0.00000 + 0.5), width: floor(group4.width * 1.00000 + 0.5) - floor(group4.width * 0.00000 + 0.5), height: floor(group4.height * 1.00000 + 0.5) - floor(group4.height * 0.00000 + 0.5)))
    context?.saveGState()
    context?.setShadow(offset: shadowOffset, blur: shadowBlurRadius, color: (shadow as UIColor).cgColor)
    backgroundColor.setFill()
    oval5Path.fill()
    context?.restoreGState()
    
    strokeColor.setStroke()
    oval5Path.lineWidth = 0.5
    oval5Path.stroke()
    
    
    //// Polygon Drawing
    let polygonPath = UIBezierPath()
    polygonPath.move(to: CGPoint(x: group4.minX + 0.19375 * group4.width, y: group4.minY + 0.50625 * group4.height))
    polygonPath.addLine(to: CGPoint(x: group4.minX + 0.44219 * group4.width, y: group4.minY + 0.25727 * group4.height))
    polygonPath.addLine(to: CGPoint(x: group4.minX + 0.44219 * group4.width, y: group4.minY + 0.75523 * group4.height))
    polygonPath.addLine(to: CGPoint(x: group4.minX + 0.19375 * group4.width, y: group4.minY + 0.50625 * group4.height))
    polygonPath.close()
    fillColor.setFill()
    polygonPath.fill()
    strokeColor.setStroke()
    polygonPath.lineWidth = 0.5
    polygonPath.stroke()
    
    
    //// Polygon 2 Drawing
    let polygon2Path = UIBezierPath()
    polygon2Path.move(to: CGPoint(x: group4.minX + 0.80625 * group4.width, y: group4.minY + 0.50625 * group4.height))
    polygon2Path.addLine(to: CGPoint(x: group4.minX + 0.55781 * group4.width, y: group4.minY + 0.25727 * group4.height))
    polygon2Path.addLine(to: CGPoint(x: group4.minX + 0.55781 * group4.width, y: group4.minY + 0.75523 * group4.height))
    polygon2Path.addLine(to: CGPoint(x: group4.minX + 0.80625 * group4.width, y: group4.minY + 0.50625 * group4.height))
    polygon2Path.close()
    fillColor.setFill()
    polygon2Path.fill()
    strokeColor.setStroke()
    polygon2Path.lineWidth = 0.5
    polygon2Path.stroke()
  }
  
  //// Generated Images
  
  class func imageOfThumb(frame: CGRect) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
    StyleImages.drawThumb(frame: frame)
    
    let imageOfThumb = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    
    return imageOfThumb
  }
}
