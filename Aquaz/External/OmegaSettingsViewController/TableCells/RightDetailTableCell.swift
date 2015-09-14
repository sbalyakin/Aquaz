//
//  RightDetailTableCell.swift
//  OmegaSettingsViewController
//
//  Created by Sergey Balyakin on 03.03.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class RightDetailTableCell<Value: CustomStringConvertible>: TableCellWithValue<Value> {
  
  var title: String { didSet { uiCell?.textLabel?.text = title } }
  var image: UIImage? { didSet { uiCell?.imageView?.image = image } }
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
  
  override func createUICell(tableView tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
    if uiCell == nil {
      uiCell = UITableViewCell(style: .Value1, reuseIdentifier: nil)
    }
    
    uiCell!.textLabel?.text = title
    uiCell!.imageView?.image = image
    uiCell!.detailTextLabel?.text = stringFromValueFunction?(value) ?? value.description
    uiCell!.detailTextLabel?.textColor = container.rightDetailValueColor
    if let accessoryType = accessoryType {
      uiCell!.accessoryType = accessoryType
    }
    return uiCell!
  }
  
  override func valueDidChange() {
    super.valueDidChange()
    uiCell?.detailTextLabel?.text = stringFromValueFunction?(value) ?? value.description
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
    uiCell!.detailTextLabel?.textColor = enable ? container.rightDetailSelectedValueColor : container.rightDetailValueColor
  }
  
}
