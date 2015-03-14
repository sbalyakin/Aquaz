//
//  TextFieldTableCell.swift
//  OmegaSettingsViewController
//
//  Created by Sergey Balyakin on 03.03.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class TextFieldTableCell<Value: Printable>: TableCellWithValue<Value>, UITextFieldTableViewCellDelegate {
  
  var title: String { didSet { uiCell?.textLabel?.text = title } }
  var uiCell: UITextFieldTableViewCell?
  var textFieldBorderStyle: UITextBorderStyle {
    didSet {
      uiCell?.textField.borderStyle = textFieldBorderStyle
    }
  }
  var keyboardType: UIKeyboardType {
    didSet {
      uiCell?.textField.keyboardType = keyboardType
    }
  }
  private var selectionIsProcessing = false
  let valueFromStringFunction: ValueFromStringFunction
  
  override var supportsPermanentActivation: Bool { return true }

  typealias ValueFromStringFunction = (String) -> Value?
  
  init(title: String, value: Value, valueFromStringFunction: ValueFromStringFunction, container: TableCellsContainer, keyboardType: UIKeyboardType = .Default, textFieldBorderStyle: UITextBorderStyle = .None) {
    self.title = title
    self.textFieldBorderStyle = textFieldBorderStyle
    self.keyboardType = keyboardType
    self.valueFromStringFunction = valueFromStringFunction
    super.init(value: value, container: container)
  }
  
  override func createUICell(#tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
    if uiCell == nil {
      uiCell = UITextFieldTableViewCell()
    }
    
    uiCell!.textLabel?.text = title
    uiCell!.textField.text = stringFromValueFunction?(value) ?? value.description
    uiCell!.textField.keyboardType = keyboardType
    uiCell!.textField.borderStyle = textFieldBorderStyle
    uiCell!.textField.textAlignment = .Right
    uiCell!.delegate = self
    return uiCell!
  }
  
  override func valueDidChange() {
    super.valueDidChange()
    uiCell?.textField.text = value.description
  }
  
  override func setActive(active: Bool) {
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
  
  func textFieldDidBeginEditing(textField: UITextField) {
    container.activateTableCell(self)
  }
  
  func textFieldDidEndEditing(textField: UITextField) {
    if let value = valueFromStringFunction(textField.text) {
      self.value = value
    }
  }
  
}