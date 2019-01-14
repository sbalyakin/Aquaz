//
//  GlanceBadge.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 20.10.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation
import WatchKit

final class ProgressHelper {
  
  static func calcAnimationParameters(imagesCount: Int, fromCurrentAmount: Double, fromTotalAmount: Double, toCurrentAmount: Double, toTotalAmount: Double, maximumAnimationDuration: Double = 1) -> (imageRange: NSRange, animationDuration: Double) {
    let progressFrom = max(0, min(1, fromCurrentAmount / fromTotalAmount))
    let progressTo = max(0, min(1, toCurrentAmount / toTotalAmount))
    let rangeStart = Int(progressFrom * Double(imagesCount))
    let rangeEnd = Int(progressTo * Double(imagesCount))
    let range = NSMakeRange(min(rangeStart, rangeEnd), abs(rangeEnd - rangeStart) + 1)
    let animationDuration = maximumAnimationDuration * (progressTo - progressFrom)
    return (imageRange: range, animationDuration: animationDuration)
  }
  
  struct TextProgressItem {
    let text: String
    let color: UIColor
    let font: UIFont
    
    var attributes: [NSAttributedString.Key: Any] {
      return [
        .font: font,
        .foregroundColor: color
      ]
    }
    
    var size: CGSize {
      return text.size(withAttributes: attributes)
    }
  }
  
  static func generateTextProgressImage(imageSize: CGSize, title: TextProgressItem, subTitle: TextProgressItem, upTitle: TextProgressItem) -> UIImage {
    let scale = WKInterfaceDevice.current().screenScale
    UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
    
    drawBadgeImageInCurrentContext(imageSize: imageSize, title: title, subTitle: subTitle, upTitle: upTitle)
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    
    return image!
  }
  
  fileprivate static func drawBadgeImageInCurrentContext(imageSize: CGSize, title: TextProgressItem, subTitle: TextProgressItem, upTitle: TextProgressItem) {
    let center = CGPoint(x: imageSize.width / 2, y: imageSize.height / 2)

    let titleSize    = title.size
    let subTitleSize = subTitle.size
    let upTitleSize  = upTitle.size

    let upTitleRect = CGRect(
      x: center.x - upTitleSize.width / 2,
      y: center.y - (upTitleSize.height / 2 + titleSize.height + subTitleSize.height) / 2,
      width: upTitleSize.width,
      height: upTitleSize.height)

    let titleRect = CGRect(
      x: center.x - titleSize.width / 2,
      y: upTitleRect.maxY - upTitleSize.height / 4,
      width: titleSize.width,
      height: titleSize.height)
    
    let subTitleRect = CGRect(
      x: center.x - subTitleSize.width / 2,
      y: titleRect.maxY - subTitleSize.height / 4,
      width: subTitleSize.width,
      height: subTitleSize.height)
    
    upTitle.text.draw(in: upTitleRect.integral, withAttributes: upTitle.attributes)
    subTitle.text.draw(in: subTitleRect.integral, withAttributes: subTitle.attributes)
    title.text.draw(in: titleRect.integral, withAttributes: title.attributes)
  }
}
