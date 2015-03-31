//
//  BasicTableCell.swift
//  OmegaSettingsViewController
//
//  Created by Sergey Balyakin on 03.03.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class BasicTableCell: TableCell {
  
  var title: String { didSet { uiCell?.textLabel?.text = title } }
  var image: UIImage? { didSet { uiCell?.imageView?.image = image } }
  var accessoryType: UITableViewCellAccessoryType? { didSet { uiCell?.accessoryType = accessoryType ?? .None } }
  var uiCell: UITableViewCell?
  
  init(title: String, container: TableCellsContainer, accessoryType: UITableViewCellAccessoryType? = nil) {
    self.title = title
    self.accessoryType = accessoryType
    super.init(container: container)
  }
  
  override func createUICell(#tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
    if uiCell == nil {
      uiCell = UITableViewCell(style: .Default, reuseIdentifier: nil)
    }
    
    uiCell!.textLabel?.text = title
    uiCell!.imageView?.image = image
    if let accessoryType = accessoryType {
      uiCell!.accessoryType = accessoryType
    }
    
    return uiCell!
  }
  
}
