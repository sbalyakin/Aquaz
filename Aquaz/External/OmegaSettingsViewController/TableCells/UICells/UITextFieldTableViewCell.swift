//
//  UITextFieldTableViewCell.swift
//  OmegaSettingsViewController
//
//  Created by Sergey Balyakin on 03.03.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

protocol UITextFieldTableViewCellDelegate: class {
  func textFieldDidBeginEditing(textField: UITextField)
  func textFieldDidEndEditing(textField: UITextField)
}

class UITextFieldTableViewCell: UITableViewCell {
  
  weak var textField: UITextField!
  var delegate: UITextFieldTableViewCellDelegate?
  
  override init() {
    super.init()
    baseInit()
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    baseInit()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    baseInit()
  }
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    baseInit()
  }
  
  private func baseInit() {
    if self.textField == nil {
      let textField = UITextField()
      textField.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
      textField.delegate = self
      self.accessoryView = textField
      self.textField = textField
    }
  }
}

extension UITextFieldTableViewCell: UITextFieldDelegate {
  func textFieldDidBeginEditing(textField: UITextField) {
    delegate?.textFieldDidBeginEditing(textField)
  }
  
  func textFieldDidEndEditing(textField: UITextField) {
    delegate?.textFieldDidEndEditing(textField)
  }
}