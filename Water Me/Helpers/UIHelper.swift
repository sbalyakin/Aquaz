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
    titleLabel.backgroundColor = UIColor.clearColor()
    titleLabel.text = titleText
    titleLabel.font = titleFont
    titleLabel.textAlignment = .Center
    container.addSubview(titleLabel)
    
    let subtitleRect = container.bounds.rectByOffsetting(dx: 0, dy: round(yOffset + titleHeight))
    let subtitleLabel = UILabel(frame: subtitleRect)
    subtitleLabel.autoresizingMask = titleLabel.autoresizingMask
    subtitleLabel.backgroundColor = UIColor.clearColor()
    subtitleLabel.text = subtitleText
    subtitleLabel.font = subtitleFont
    subtitleLabel.textAlignment = .Center
    container.addSubview(subtitleLabel)

    return (containerView: container, titleLabel: titleLabel, subtitleLabel: subtitleLabel)
  }
  
}

extension UIColor {
  func isClearColor() -> Bool {
    var white: CGFloat = 0
    var alpha: CGFloat = 0
    let result = getWhite(&white, alpha: &alpha)
    return result && white == 0 && alpha == 0
  }
}
