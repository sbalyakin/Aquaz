//
//  UIPickerTableViewCell.swift
//  OmegaSettingsViewController
//
//  Created by Sergey Balyakin on 03.03.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

protocol UIPickerTableViewCellDataSource {
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String!
}

protocol UIPickerTableViewCellDelegate {
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
}

class UIPickerTableViewCell: UITableViewCell {
  
  weak var pickerView: UIPickerView!
  var dataSource: UIPickerTableViewCellDataSource?
  var delegate: UIPickerTableViewCellDelegate?
  
  override init() {
    super.init()
    baseInit()
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    baseInit()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    baseInit()
  }
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    baseInit()
  }
  
  private func baseInit() {
    selectionStyle = .None
    
    layer.zPosition = -1
    if self.pickerView == nil {
      let pickerView = UIPickerView()
      pickerView.backgroundColor = UIColor.clearColor()
      pickerView.dataSource = self
      pickerView.delegate = self
      contentView.addSubview(pickerView)
      contentView.sendSubviewToBack(pickerView)
      self.pickerView = pickerView
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    pickerView.frame = contentView.bounds
  }
}

extension UIPickerTableViewCell: UIPickerViewDataSource {
  
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return dataSource?.numberOfComponentsInPickerView(pickerView) ?? 1
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return dataSource?.pickerView(pickerView, numberOfRowsInComponent: component) ?? 0
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
    return dataSource?.pickerView(pickerView, titleForRow: row, forComponent: component) ?? ""
  }
}

extension UIPickerTableViewCell: UIPickerViewDelegate {
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    delegate?.pickerView(pickerView, didSelectRow: row, inComponent: component)
  }
}
