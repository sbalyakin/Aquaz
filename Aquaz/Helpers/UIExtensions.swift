//
//  UIExtensions.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 07.04.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

extension UIColor {
  func isClearColor() -> Bool {
    var white: CGFloat = 0
    var alpha: CGFloat = 0
    let result = getWhite(&white, alpha: &alpha)
    return result && white == 0 && alpha == 0
  }
  
  func colorWithHue(newHue: CGFloat) -> UIColor {
    var saturation: CGFloat = 1.0, brightness: CGFloat = 1.0, alpha: CGFloat = 1.0
    self.getHue(nil, saturation: &saturation, brightness: &brightness, alpha: &alpha)
    return UIColor(hue: newHue, saturation: saturation, brightness: brightness, alpha: alpha)
  }
  
  func colorWithSaturation(newSaturation: CGFloat) -> UIColor {
    var hue: CGFloat = 1.0, brightness: CGFloat = 1.0, alpha: CGFloat = 1.0
    self.getHue(&hue, saturation: nil, brightness: &brightness, alpha: &alpha)
    return UIColor(hue: hue, saturation: newSaturation, brightness: brightness, alpha: alpha)
  }
  
  func colorWithBrightness(newBrightness: CGFloat) -> UIColor {
    var hue: CGFloat = 1.0, saturation: CGFloat = 1.0, alpha: CGFloat = 1.0
    self.getHue(&hue, saturation: &saturation, brightness: nil, alpha: &alpha)
    return UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha)
  }
  
  func colorWithAlpha(newAlpha: CGFloat) -> UIColor {
    var hue: CGFloat = 1.0, saturation: CGFloat = 1.0, brightness: CGFloat = 1.0
    self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
    return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: newAlpha)
  }
  
  func colorWithHighlight(highlight: CGFloat) -> UIColor {
    var red: CGFloat = 1.0, green: CGFloat = 1.0, blue: CGFloat = 1.0, alpha: CGFloat = 1.0
    self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    return UIColor(red: red * (1-highlight) + highlight, green: green * (1-highlight) + highlight, blue: blue * (1-highlight) + highlight, alpha: alpha * (1-highlight) + highlight)
  }
  
  func colorWithShadow(shadow: CGFloat) -> UIColor {
    var red: CGFloat = 1.0, green: CGFloat = 1.0, blue: CGFloat = 1.0, alpha: CGFloat = 1.0
    self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    return UIColor(red: red * (1-shadow), green: green * (1-shadow), blue: blue * (1-shadow), alpha: alpha * (1-shadow) + shadow)
  }
}

extension UIView {
  public func liveDebugLog(message: String) {
    #if !(TARGET_OS_IPHONE)
      let logPath = "/tmp/XcodeLiveRendering.log"
      if !NSFileManager.defaultManager().fileExistsAtPath(logPath) {
        NSFileManager.defaultManager().createFileAtPath(logPath, contents: NSData(), attributes: nil)
      }
      
      if let fileHandle = NSFileHandle(forWritingAtPath: logPath) {
        fileHandle.seekToEndOfFile()
        
        let date = NSDate()
        let bundle = NSBundle(forClass: self.dynamicType)
        if let application: AnyObject = bundle.objectForInfoDictionaryKey("CFBundleName") {
          if let data = "\(date) \(application) \(message)\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) {
            fileHandle.writeData(data)
          }
        }
      }
    #endif
  }
  
  func addConstraints(constraintsVisualFormat: String, views: [String: UIView], metrics: [NSObject: AnyObject]? = nil, options: NSLayoutFormatOptions = NSLayoutFormatOptions.allZeros) {
    let constraints = NSLayoutConstraint.constraintsWithVisualFormat(constraintsVisualFormat, options: options, metrics: metrics, views: views)
    self.addConstraints(constraints)
  }
  
}

extension UILabel {
  
  func setTextWithAnimation(text: String, callback: (() -> ())? = nil) {
    if self.text == text {
      return
    }
    
    let duration: NSTimeInterval = 0.3
    
    UIView.animateWithDuration(duration / 2, delay: 0, options: .CurveEaseInOut, animations: { self.alpha = 0 } ) {
      (completed) -> Void in
      self.text = text
      callback?()
      
      UIView.animateWithDuration(duration / 2, delay: 0, options: .CurveEaseInOut, animations: {
        self.alpha = 1
        }, completion: nil)
    }
  }
  
}

extension UIViewController {
  
  func contentViewController() -> UIViewController {
    if let navigationController = self as? UINavigationController {
      return navigationController.visibleViewController
    } else {
      return self
    }
  }
  
}