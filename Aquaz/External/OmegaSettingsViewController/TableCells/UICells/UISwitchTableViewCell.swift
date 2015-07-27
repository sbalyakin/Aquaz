//
//  UISwitchTableViewCell.swift
//  OmegaSettingsViewController
//
//  Created by Sergey Balyakin on 03.03.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

protocol UISwitchTableViewCellDelegate: class {
  
  func switchControlValueChanged(switchControl: UISwitch, on: Bool)
  
}

class UISwitchTableViewCell: UITableViewCell {
  
  weak var switchControl: UISwitch!
  
  weak var delegate: UISwitchTableViewCellDelegate?

  init(reuseIdentifier: String? = nil) {
    super.init(style: .Default, reuseIdentifier: reuseIdentifier)
    baseInit()
  }

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    baseInit()
  }
  
  private func baseInit() {
    if self.switchControl == nil {
      let switchControl = UISwitch()
      switchControl.addTarget(self, action: "switchControlValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
      self.accessoryView = switchControl
      self.switchControl = switchControl
    }
  }
  
  func switchControlValueChanged(switchControl: UISwitch) {
    delegate?.switchControlValueChanged(switchControl, on: switchControl.on)
  }
}