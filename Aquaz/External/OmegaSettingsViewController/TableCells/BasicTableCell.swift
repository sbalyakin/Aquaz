//
//  BasicTableCell.swift
//  OmegaSettingsViewController
//
//  Created by Sergey Balyakin on 03.03.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class BasicTableCell: TableCell {
  
  var title: String { didSet { uiCell?.textLabel?.text = title } }
  var textColor: UIColor? { didSet { uiCell?.textLabel?.textColor = textColor ?? UIColor.black } }
  var image: UIImage? { didSet { uiCell?.imageView?.image = image } }
  var accessoryType: UITableViewCell.AccessoryType? { didSet { uiCell?.accessoryType = accessoryType ?? .none } }
  var uiCell: UITableViewCell?
  
  init(title: String, container: TableCellsContainer, accessoryType: UITableViewCell.AccessoryType? = nil) {
    self.title = title
    self.accessoryType = accessoryType
    super.init(container: container)
  }
  
  override func createUICell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
    if uiCell == nil {
      uiCell = UITableViewCell(style: .default, reuseIdentifier: nil)
    }
    
    uiCell!.textLabel?.text = title
    uiCell!.imageView?.image = image

    if let accessoryType = accessoryType {
      uiCell!.accessoryType = accessoryType
    }
    
    if let textColor = textColor {
      uiCell!.textLabel?.textColor = textColor
    }
    
    return uiCell!
  }
  
}
