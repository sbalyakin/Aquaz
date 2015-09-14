//
//  TableCell.swift
//  OmegaSettingsViewController
//
//  Created by Sergey Balyakin on 03.03.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class TableCell {
  
  weak var container: TableCellsContainer!
  var active = false
  var tableCellDidActivateFunction: TableCellActivatedFunction?
  var isSupportingCell: Bool { return false }
  var supportsPermanentActivation: Bool { return false }
  
  typealias TableCellActivatedFunction = (TableCell, Bool) -> ()
  
  init(container: TableCellsContainer) {
    self.container = container
  }
  
  func createUICell(tableView tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
    assert(false, "createUICell function must be overriden by descendants")
    return UITableViewCell()
  }
  
  func getRowHeight() -> CGFloat? {
    return nil
  }
  
  func setActive(active: Bool) {
    self.active = active
    tableCellDidActivateFunction?(self, active)
    if !supportsPermanentActivation {
      self.active = false
    }
  }
  
  func writeToExternalStorage() {
    // It's used in TableCellWithValue
  }
  
  func readFromExternalStorage() {
    // It's used in TableCellWithValue
  }
  
}

