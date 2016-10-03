//
//  UISwitchTableViewCell.swift
//  OmegaSettingsViewController
//
//  Created by Sergey Balyakin on 03.03.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

protocol UISwitchTableViewCellDelegate: class {
  
  func switchControlValueChanged(_ switchControl: UISwitch, on: Bool)
  
}

class UISwitchTableViewCell: UITableViewCell {
  
  weak var switchControl: UISwitch!
  
  weak var delegate: UISwitchTableViewCellDelegate?

  init(reuseIdentifier: String? = nil) {
    super.init(style: .default, reuseIdentifier: reuseIdentifier)
    baseInit()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    baseInit()
  }
  
  fileprivate func baseInit() {
    if self.switchControl == nil {
      let switchControl = UISwitch()
      
      switchControl.addTarget(
        self,
        action: #selector(self.switchControlValueChanged(_:)),
        for: UIControlEvents.valueChanged)
      
      self.accessoryView = switchControl
      self.switchControl = switchControl
    }
  }
  
  func switchControlValueChanged(_ switchControl: UISwitch) {
    delegate?.switchControlValueChanged(switchControl, on: switchControl.isOn)
  }
}
