//
//  UIHelper.swift
//  Water Me
//
//  Created by Sergey Balyakin on 05.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class UIHelper {
  
  class func createNavigationTitleViewWithSubTitle(#navigationController: UINavigationController, titleText: String? = nil, subtitleText: String? = nil) -> (containerView: UIView, titleLabel: UILabel, subtitleLabel: UILabel) {
    let titleFont = UIFont.boldSystemFontOfSize(16)
    let subtitleFont = UIFont.systemFontOfSize(12)
    let titleHeight = titleFont.lineHeight
    let subtitleHeight = subtitleFont.lineHeight
    let yOffset = -subtitleHeight / 2
    
    let containerRect = navigationController.navigationBar.frame.rectByInsetting(dx: 100, dy: 0)
    let container = UIView(frame: containerRect)
    
    let titleRect = container.bounds.rectByOffsetting(dx: 0, dy: round(yOffset))
    let titleLabel = UILabel(frame: titleRect)
    titleLabel.autoresizingMask = .FlexibleWidth
    titleLabel.textColor = StyleKit.barTextColor
    titleLabel.backgroundColor = UIColor.clearColor()
    titleLabel.text = titleText
    titleLabel.font = titleFont
    titleLabel.textAlignment = .Center
    container.addSubview(titleLabel)
    
    let subtitleRect = container.bounds.rectByOffsetting(dx: 0, dy: round(yOffset + titleHeight))
    let subtitleLabel = UILabel(frame: subtitleRect)
    subtitleLabel.autoresizingMask = titleLabel.autoresizingMask
    subtitleLabel.textColor = StyleKit.barTextColor
    subtitleLabel.backgroundColor = UIColor.clearColor()
    subtitleLabel.text = subtitleText
    subtitleLabel.font = subtitleFont
    subtitleLabel.textAlignment = .Center
    container.addSubview(subtitleLabel)

    return (containerView: container, titleLabel: titleLabel, subtitleLabel: subtitleLabel)
  }

  class func applyStylization() {
    UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
    UISegmentedControl.appearance().tintColor = StyleKit.controlTintColor
    UIButton.appearance().tintColor = StyleKit.controlTintColor
    UISwitch.appearance().onTintColor = StyleKit.controlTintColor
    UIBarButtonItem.appearance().tintColor = StyleKit.barTextColor
    UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: StyleKit.barTextColor], forState: .Normal)
    UINavigationBar.appearance().tintColor = StyleKit.barTextColor
    UINavigationBar.appearance().tintAdjustmentMode = .Normal
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
