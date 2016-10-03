//
//  RoundedButton.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 16.01.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

@IBDesignable class RoundedButton: UIButton {
  
  enum RoundMode: Int {
    case custom
    case height
    case width
    case auto
  }
  
  @IBInspectable var cornerRadius: CGFloat = 0
  @IBInspectable var roundMode: Int = 0 {
    didSet {
      _roundMode = RoundMode(rawValue: roundMode) ?? .custom
    }
  }
  var _roundMode: RoundMode = .custom
  
  override func layoutSubviews() {
    super.layoutSubviews()
    applyCornerRadius()
  }
  
  @available(iOS 8.0, *)
  override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()

    applyCornerRadius()
  }

  fileprivate func applyCornerRadius() {
    switch _roundMode {
    case .custom: layer.cornerRadius = cornerRadius
    case .height: layer.cornerRadius = bounds.height / 2
    case .width:  layer.cornerRadius = bounds.width / 2
    case .auto:   layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }
  }
}
