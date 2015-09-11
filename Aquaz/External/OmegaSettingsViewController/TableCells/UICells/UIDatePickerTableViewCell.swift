//
//  UIDatePickerTableViewCell.swift
//  OmegaSettingsViewController
//
//  Created by Admin on 06.03.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

protocol UIDatePickerTableViewCellDelegate: class {
  
  func datePickerValueDidChange(datePicker: UIDatePicker)
  
}

class UIDatePickerTableViewCell: UITableViewCell {
  
  weak var datePicker: UIDatePicker!
  
  weak var delegate: UIDatePickerTableViewCellDelegate?
  
  init(reuseIdentifier: String? = nil) {
    super.init(style: .Default, reuseIdentifier: reuseIdentifier)
    baseInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    baseInit()
  }
  
  private func baseInit() {
    selectionStyle = .None
    layer.zPosition = -1
    
    if self.datePicker == nil {
      let datePicker = UIDatePicker()
      datePicker.backgroundColor = UIColor.clearColor()
      datePicker.addTarget(self, action: "datePickerValueDidChange:", forControlEvents: UIControlEvents.ValueChanged)
      contentView.addSubview(datePicker)
      contentView.sendSubviewToBack(datePicker)
      self.datePicker = datePicker
    }
  }
  
  func datePickerValueDidChange(datePicker: UIDatePicker) {
    delegate?.datePickerValueDidChange(datePicker)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    layoutDatePicker()
  }
  
  private func layoutDatePicker() {
    datePicker.frame = bounds
    datePicker.setNeedsLayout()
  }
  
}

