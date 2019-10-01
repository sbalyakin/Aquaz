//
//  UIControlExtensions.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 20.10.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

extension UIView {
  func liveDebugLog(_ message: String) {
    #if !(TARGET_OS_IPHONE)
      let logPath = "/tmp/XcodeLiveRendering.log"
      if !FileManager.default.fileExists(atPath: logPath) {
        FileManager.default.createFile(atPath: logPath, contents: Data(), attributes: nil)
      }
      
      if let fileHandle = FileHandle(forWritingAtPath: logPath) {
        fileHandle.seekToEndOfFile()
        
        let date = Date()
        let bundle = Bundle(for: type(of: self))
        if let application: Any = bundle.object(forInfoDictionaryKey: "CFBundleName") as Any? {
          if let data = "\(date) \(application) \(message)\n".data(using: String.Encoding.utf8, allowLossyConversion: true) {
            fileHandle.write(data)
          }
        }
      }
    #endif
  }
  
  func addConstraints(_ constraintsVisualFormat: String, views: [String: UIView], metrics: [String: Any]? = nil, options: NSLayoutConstraint.FormatOptions = NSLayoutConstraint.FormatOptions()) {
    let constraints = NSLayoutConstraint.constraints(withVisualFormat: constraintsVisualFormat, options: options, metrics: metrics, views: views)
    self.addConstraints(constraints)
  }
  
}

extension UILabel {
  
  func setTextWithAnimation(_ text: String, callback: (() -> ())? = nil) {
    if self.text == text {
      return
    }
    
    let duration: TimeInterval = 0.3
    
    UIView.animate(withDuration: duration / 2, delay: 0, options: UIView.AnimationOptions(), animations: { self.alpha = 0 } ) {
      (completed) -> Void in
      self.text = text
      callback?()
      
      UIView.animate(withDuration: duration / 2, delay: 0, options: UIView.AnimationOptions(), animations: {
        self.alpha = 1
        }, completion: nil)
    }
  }
  
}
