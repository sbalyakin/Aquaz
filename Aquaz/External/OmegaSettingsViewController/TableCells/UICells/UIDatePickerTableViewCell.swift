//
//  UIDatePickerTableViewCell.swift
//  OmegaSettingsViewController
//
//  Created by Sergey Balyakin on 06.03.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

protocol UIDatePickerTableViewCellDelegate: class {
  
  func datePickerValueDidChange(_ datePicker: UIDatePicker)
  
}

class UIDatePickerTableViewCell: UITableViewCell {
  
  weak var datePicker: UIDatePicker!
  
  weak var delegate: UIDatePickerTableViewCellDelegate?
  
  init(reuseIdentifier: String? = nil) {
    super.init(style: .default, reuseIdentifier: reuseIdentifier)
    baseInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    baseInit()
  }
  
  fileprivate func baseInit() {
    selectionStyle = .none
    layer.zPosition = -1
    
    if self.datePicker == nil {
      let datePicker = UIDatePicker()
      datePicker.backgroundColor = UIColor.clear
      
      datePicker.addTarget(
        self,
        action: #selector(self.datePickerValueDidChange(_:)),
        for: UIControlEvents.valueChanged)
      
      contentView.addSubview(datePicker)
      contentView.sendSubview(toBack: datePicker)
      self.datePicker = datePicker
    }
  }
  
  @objc func datePickerValueDidChange(_ datePicker: UIDatePicker) {
    delegate?.datePickerValueDidChange(datePicker)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    layoutDatePicker()
  }
  
  fileprivate func layoutDatePicker() {
    datePicker.frame = bounds
    datePicker.setNeedsLayout()
  }
  
}

