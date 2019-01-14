//
//  TextFieldTableCell.swift
//  OmegaSettingsViewController
//
//  Created by Sergey Balyakin on 03.03.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class TextFieldTableCell<Value: CustomStringConvertible>: TableCellWithValue<Value>, UITextFieldTableViewCellDelegate {
  
  var title: String { didSet { uiCell?.textLabel?.text = title } }
  var image: UIImage? { didSet { uiCell?.imageView?.image = image } }
  var uiCell: UITextFieldTableViewCell?
  
  var textFieldBorderStyle: UITextField.BorderStyle {
    didSet {
      uiCell?.textField.borderStyle = textFieldBorderStyle
    }
  }
  
  var keyboardType: UIKeyboardType {
    didSet {
      uiCell?.textField.keyboardType = keyboardType
    }
  }
  
  // Value initialization was moved to init() in order to solve Swift 2.2 bug on iOS7
  // More details here https://bugs.swift.org/browse/SR-815
  fileprivate var selectionIsProcessing: Bool

  let valueFromStringFunction: ValueFromStringFunction
  
  override var supportsPermanentActivation: Bool { return true }

  typealias ValueFromStringFunction = (String) -> Value?
  
  init(title: String, value: Value, valueFromStringFunction: @escaping ValueFromStringFunction, container: TableCellsContainer, keyboardType: UIKeyboardType = .default, textFieldBorderStyle: UITextField.BorderStyle = .none) {
    self.title = title
    self.textFieldBorderStyle = textFieldBorderStyle
    self.keyboardType = keyboardType
    self.valueFromStringFunction = valueFromStringFunction
    
    selectionIsProcessing = false
    
    super.init(value: value, container: container)
  }
  
  override func createUICell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
    if uiCell == nil {
      uiCell = UITextFieldTableViewCell()
    }
    
    uiCell!.textLabel?.text = title
    uiCell!.imageView?.image = image
    uiCell!.textField.text = stringFromValueFunction?(value) ?? value.description
    uiCell!.textField.textColor = container.rightDetailValueColor
    uiCell!.textField.font = uiCell!.textLabel!.font
    uiCell!.textField.keyboardType = keyboardType
    uiCell!.textField.borderStyle = textFieldBorderStyle
    uiCell!.textField.textAlignment = .right
    uiCell!.delegate = self
    return uiCell!
  }
  
  override func valueDidChange() {
    super.valueDidChange()
    uiCell?.textField.text = stringFromValueFunction?(value) ?? value.description
  }
  
  override func setActive(_ active: Bool) {
    if selectionIsProcessing {
      return
    }

    selectionIsProcessing = true

    if self.active && !active {
      uiCell?.textField.resignFirstResponder()
    } else if active {
      uiCell?.textField.becomeFirstResponder()
    }
    
    super.setActive(active)
    selectionIsProcessing = false
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    container.activateTableCell(self)
    uiCell?.textField?.textColor = container.rightDetailSelectedValueColor
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    if let value = valueFromStringFunction(textField.text ?? "") {
      self.value = value
    }
    uiCell?.textField?.textColor = container.rightDetailValueColor
    if active {
      container.activateTableCell(nil)
    }

  }
  
}
