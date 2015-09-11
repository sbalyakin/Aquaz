//
//  SwitchTableCell.swift
//  OmegaSettingsViewController
//
//  Created by Sergey Balyakin on 03.03.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class SwitchTableCell<Value: BooleanType where Value: BooleanLiteralConvertible, Value.BooleanLiteralType == Bool>: TableCellWithValue<Value>, UISwitchTableViewCellDelegate {
  
  var title: String { didSet { uiCell?.textLabel?.text = title } }
  var image: UIImage? { didSet { uiCell?.imageView?.image = image } }
  var uiCell: UISwitchTableViewCell?
  
  init(title: String, value: Value, container: TableCellsContainer) {
    self.title = title
    super.init(value: value, container: container)
  }
  
  override func createUICell(tableView tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
    if uiCell == nil {
      uiCell = UISwitchTableViewCell()
    }
    
    uiCell!.textLabel?.text = title
    uiCell!.imageView?.image = image
    uiCell!.switchControl.setOn(value.boolValue, animated: false)
    uiCell!.delegate = self
    return uiCell!
  }

  override func valueDidChange() {
    super.valueDidChange()
    uiCell?.switchControl.setOn(value.boolValue, animated: true)
  }
  
  func switchControlValueChanged(switchControl: UISwitch, on: Bool) {
    value = Value(booleanLiteral: on)

    if !active {
      container.activateTableCell(self)
    }
  }
  
}
