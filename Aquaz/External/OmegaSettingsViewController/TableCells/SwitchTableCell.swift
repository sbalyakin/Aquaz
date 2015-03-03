//
//  SwitchTableCell.swift
//  OmegaSettingsViewController
//
//  Created by Sergey Balyakin on 03.03.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class SwitchTableCell<Value: BooleanType>: TableCellWithValue<Value>, UISwitchTableViewCellDelegate {
  
  override var value: Value { didSet { uiCell?.switchControl.setOn(value.boolValue, animated: true) } }
  var title: String { didSet { uiCell?.textLabel?.text = title } }
  var uiCell: UISwitchTableViewCell?
  
  init(title: String, value: Value, container: TableCellsContainer) {
    self.title = title
    super.init(value: value, container: container)
  }
  
  override func createUICell(#tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
    if uiCell == nil {
      uiCell = UISwitchTableViewCell(style: .Default, reuseIdentifier: nil)
    }
    
    uiCell!.textLabel?.text = title
    uiCell!.switchControl.setOn(value.boolValue, animated: false)
    uiCell!.delegate = self
    return uiCell!
  }
  
  func switchControlValueChanged(switchControl: UISwitch, on: Bool) {
    if !active {
      container.activateTableCell(self)
    }
  }
  
}
