//
//  UITextFieldTableViewCell.swift
//  OmegaSettingsViewController
//
//  Created by Sergey Balyakin on 03.03.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

protocol UITextFieldTableViewCellDelegate: class {
  func textFieldDidBeginEditing(_ textField: UITextField)
  func textFieldDidEndEditing(_ textField: UITextField)
}

class UITextFieldTableViewCell: UITableViewCell {
  
  weak var textField: UITextField!
  weak var delegate: UITextFieldTableViewCellDelegate?
  
  init(reuseIdentifier: String? = nil) {
    super.init(style: .default, reuseIdentifier: reuseIdentifier)
    baseInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    baseInit()
  }
  
  fileprivate func baseInit() {
    if self.textField == nil {
      let textField = UITextField()
      textField.frame = CGRect(x: 0, y: 0, width: 80, height: 30)
      textField.delegate = self
      self.accessoryView = textField
      self.textField = textField
    }
  }
}

extension UITextFieldTableViewCell: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    delegate?.textFieldDidBeginEditing(textField)
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    delegate?.textFieldDidEndEditing(textField)
  }
}
