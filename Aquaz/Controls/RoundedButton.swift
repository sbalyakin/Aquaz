//
//  RoundedButton.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 16.01.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

@IBDesignable class RoundedButton: UIButton {
  
  enum RoundMode: Int {
    case Custom
    case Height
    case Width
    case Auto
  }
  
  @IBInspectable var cornerRadius: CGFloat = 0
  @IBInspectable var roundMode: Int = 0 {
    didSet {
      _roundMode = RoundMode(rawValue: roundMode) ?? .Custom
    }
  }
  var _roundMode: RoundMode = .Custom
  
  override func layoutSubviews() {
    super.layoutSubviews()
    applyCornerRadius()
  }
  
  @available(iOS 8.0, *)
  override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()

    applyCornerRadius()
  }

  private func applyCornerRadius() {
    switch _roundMode {
    case .Custom: layer.cornerRadius = cornerRadius
    case .Height: layer.cornerRadius = bounds.height / 2
    case .Width:  layer.cornerRadius = bounds.width / 2
    case .Auto:   layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }
  }
}
