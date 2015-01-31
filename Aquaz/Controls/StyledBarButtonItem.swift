//
//  StyledBarButtonItem.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 20.01.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class StyledBarButtonItem: UIBarButtonItem {
  override init(image: UIImage?, style: UIBarButtonItemStyle, target: AnyObject?, action: Selector) {
    super.init(image: image?.imageWithRenderingMode(.AlwaysOriginal), style: style, target: target, action: action)
  }
  
  override init(image: UIImage?, landscapeImagePhone: UIImage?, style: UIBarButtonItemStyle, target: AnyObject?, action: Selector) {
    super.init(image: image?.imageWithRenderingMode(.AlwaysOriginal), landscapeImagePhone: landscapeImagePhone?.imageWithRenderingMode(.AlwaysOriginal), style: style, target: target, action: action)
  }
  
  override init(title: String?, style: UIBarButtonItemStyle, target: AnyObject?, action: Selector) {
    super.init(title: title, style: style, target: target, action: action)
  }
  
  override init(barButtonSystemItem systemItem: UIBarButtonSystemItem, target: AnyObject?, action: Selector) {
    super.init(barButtonSystemItem: systemItem, target: target, action: action)
  }
  
  override init(customView: UIView) {
    super.init(customView: customView)
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    if let image = image {
      self.image = image.imageWithRenderingMode(.AlwaysOriginal)
    }
  }

  override init() {
    super.init()
  }
  
}
