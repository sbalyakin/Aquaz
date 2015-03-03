//
//  RightDetailTableCell.swift
//  OmegaSettingsViewController
//
//  Created by Sergey Balyakin on 03.03.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class RightDetailTableCell<Value: Printable>: TableCellWithValue<Value>, TableCellWithValueDelegate {
  
  override var value: Value {
    didSet {
      uiCell?.detailTextLabel?.text = stringFromValueFunction?(value) ?? value.description
    }
  }
  
  var title: String { didSet { uiCell?.textLabel?.text = title } }
  var accessoryType: UITableViewCellAccessoryType? { didSet { uiCell?.accessoryType = accessoryType ?? .None } }
  var uiCell: UITableViewCell?
  
  var supportingTableCell: TableCellWithValue<Value>? {
    didSet {
      supportingTableCell?.baseTableCell = self
    }
  }
  
  var supportingCellIsShown: Bool = false { didSet { setHighlightForValue(supportingCellIsShown) } }
  override var supportsPermanentActivation: Bool { return supportingTableCell != nil }

  
  init(title: String, value: Value, container: TableCellsContainer, accessoryType: UITableViewCellAccessoryType? = nil) {
    self.title = title
    self.accessoryType = accessoryType
    super.init(value: value, container: container)
  }
  
  override func createUICell(#tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
    if uiCell == nil {
      uiCell = UITableViewCell(style: .Value1, reuseIdentifier: nil)
    }
    
    uiCell!.textLabel?.text = title
    uiCell!.detailTextLabel?.text = stringFromValueFunction?(value) ?? value.description
    if let accessoryType = accessoryType {
      uiCell!.accessoryType = accessoryType
    }
    return uiCell!
  }
  
  override func setActive(active: Bool) {
    if isSupportingCell {
      return
    }
    
    if let supportingTableCell = supportingTableCell {
      if active {
        supportingTableCell.value = value
        container.addSupportingTableCell(baseTableCell: self, supportingTableCell: supportingTableCell)
      } else {
        container.deleteSupportingTableCell()
      }
      
      supportingCellIsShown = active
    }
    
    super.setActive(active)
  }
  
  private func setHighlightForValue(enable: Bool) {
    uiCell!.detailTextLabel?.textColor = enable ? UIColor.redColor() : UIColor.blackColor()
  }
  
  func valueDidChange() {
    if let supportingTableCell = supportingTableCell {
      value = supportingTableCell.value
    }
  }
  
}
