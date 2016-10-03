//
//  SwitchTableCell.swift
//  OmegaSettingsViewController
//
//  Created by Sergey Balyakin on 03.03.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class SwitchTableCell: TableCellWithValue<Bool>, UISwitchTableViewCellDelegate {
  
  var title: String { didSet { uiCell?.textLabel?.text = title } }
  var image: UIImage? { didSet { uiCell?.imageView?.image = image } }
  var uiCell: UISwitchTableViewCell?
  
  init(title: String, value: Bool, container: TableCellsContainer) {
    self.title = title
    super.init(value: value, container: container)
  }
  
  override func createUICell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
    if uiCell == nil {
      uiCell = UISwitchTableViewCell()
    }
    
    uiCell!.textLabel?.text = title
    uiCell!.imageView?.image = image
    uiCell!.switchControl.setOn(value, animated: false)
    uiCell!.delegate = self
    return uiCell!
  }

  override func valueDidChange() {
    super.valueDidChange()
    uiCell?.switchControl.setOn(value, animated: true)
  }
  
  func switchControlValueChanged(_ switchControl: UISwitch, on: Bool) {
    value = on

    if !active {
      container.activateTableCell(self)
    }
  }
  
}
