//
//  UIHelper.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 05.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import UIKit

class UIHelper {
  
  class func applyStylization() {
    UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
    
    UISegmentedControl.appearance().tintColor = StyleKit.controlTintColor
    
    UIButton.appearance().tintColor = StyleKit.controlTintColor
    
    UISwitch.appearance().onTintColor = StyleKit.controlTintColor
    
    UIBarButtonItem.appearance().tintColor = StyleKit.barTextColor
    UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: StyleKit.barTextColor], forState: .Normal)
    
    UINavigationBar.appearance().barTintColor = StyleKit.barBackgroundColor
    UINavigationBar.appearance().barStyle = .Black
    UINavigationBar.appearance().tintColor = StyleKit.barTextColor
    UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: StyleKit.barTextColor]
    UINavigationBar.appearance().translucent = false
    UINavigationBar.appearance().tintAdjustmentMode = .Normal
  }
  
  class func applyStyleToNavigationBar(navigationBar: UINavigationBar) {
    navigationBar.barTintColor = StyleKit.barBackgroundColor
    navigationBar.barStyle = .Black
    navigationBar.tintColor = StyleKit.barTextColor
    navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: StyleKit.barTextColor]
    navigationBar.translucent = false
    navigationBar.tintAdjustmentMode = .Normal
  }
  
  class func applyStyle(viewController: UIViewController) {
    viewController.view.backgroundColor = StyleKit.pageBackgroundColor

    if let tableViewController = viewController as? UITableViewController {
      tableViewController.tableView.backgroundView = nil
      tableViewController.tableView.backgroundColor = UIColor.clearColor()
    } else if let settingsViewController = viewController as? OmegaSettingsViewController {
      settingsViewController.tableView.backgroundView = nil
      settingsViewController.tableView.backgroundColor = UIColor.clearColor()
    }
  }

  class func setupReveal(viewController: UIViewController) {
    if let revealViewController = viewController.revealViewController() {
      let menuImage = UIImage(named: "iconMenu")
      let revealButton = StyledBarButtonItem(image: menuImage, style: .Plain, target: revealViewController, action: "revealToggle:")
      viewController.navigationItem.setLeftBarButtonItem(revealButton, animated: true)
      viewController.navigationController?.navigationBar.addGestureRecognizer(revealViewController.panGestureRecognizer())
      viewController.view.addGestureRecognizer(revealViewController.panGestureRecognizer())
    }
  }

  class func calcFontHeight(font: UIFont) -> CGFloat {
    return adjustValueForScaleFactor(font.lineHeight)
  }
  
  class func calcTextSize(text: String, font: UIFont) -> CGSize {
    var size = text.sizeWithAttributes([NSFontAttributeName: font])
    size.width = adjustValueForScaleFactor(size.width)
    size.height = adjustValueForScaleFactor(size.height)
    return size
  }

  class func adjustValueForScaleFactor(value: CGFloat) -> CGFloat {
    let scaleFactor = UIScreen.mainScreen().scale
    return ceil(value * scaleFactor) / scaleFactor
  }
  
}

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
}

extension UILabel {
  
  func setTextWithAnimation(text: String, duration: NSTimeInterval = 0.3) {
    if self.text == text {
      return
    }
    
    UIView.animateWithDuration(duration / 2, delay: 0, options: .CurveEaseInOut, animations: { self.alpha = 0 } ) {
      (completed) -> Void in
      self.text = text
      
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
