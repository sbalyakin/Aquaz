//
//  UIControlExtensions.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 20.10.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

extension UIView {
  func liveDebugLog(message: String) {
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
  
  func addConstraints(constraintsVisualFormat: String, views: [String: UIView], metrics: [String: AnyObject]? = nil, options: NSLayoutFormatOptions = NSLayoutFormatOptions()) {
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