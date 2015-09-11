//
//  UISegmentedTableViewCell.swift
//  OmegaSettingsViewController
//
//  Created by Sergey Balyakin on 03.03.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

protocol UISegmentedTableViewCellDelegate: class {
  
  func segmentedControlValueChanged(segmentedControl: UISegmentedControl, segmentIndex: Int)
  
}

class UISegmentedTableViewCell: UITableViewCell {
  
  weak var segmentedControl: UISegmentedControl!
  
  weak var delegate: UISegmentedTableViewCellDelegate?
  
  var segmentsWidth: CGFloat = 0 {
    didSet {
      for segment in 0..<segmentedControl.numberOfSegments {
        segmentedControl.setWidth(segmentsWidth, forSegmentAtIndex: segment)
      }
    }
  }
  
  init(segmentTitles: [String]) {
    super.init(style: .Default, reuseIdentifier: nil)
    baseInit(segmentTitles)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    baseInit([])
  }
  
  private func baseInit(segmentTitles: [String]) {
    if self.segmentedControl == nil {
      let segmentedControl = UISegmentedControl(items: segmentTitles)
      segmentedControl.addTarget(self, action: "segmentedControlValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
      self.accessoryView = segmentedControl
      self.segmentedControl = segmentedControl
    }
  }
  
  func segmentedControlValueChanged(segmentedControl: UISegmentedControl) {
    delegate?.segmentedControlValueChanged(segmentedControl, segmentIndex: segmentedControl.selectedSegmentIndex)
  }
}
