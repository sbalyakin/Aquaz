//
//  EditableTableViewCell.swift
//  Water Me
//
//  Created by Sergey Balyakin on 09.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class EditableTableViewCell: UITableViewCell {
  
  @IBOutlet weak var title: UILabel!
  @IBOutlet weak var value: UITextField!
  
  var tableView: UITableView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
    if selected {
      value.becomeFirstResponder()
    } else {
      value.resignFirstResponder()
    }
  }
  
  @IBAction func valueEditingDidBegin(sender: AnyObject) {
    let indexPath = tableView.indexPathForCell(self)
    tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
  }
  
}
