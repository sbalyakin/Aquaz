//
//  DatePickerTableCell.swift
//  OmegaSettingsViewController
//
//  Created by Admin on 06.03.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

enum DatePickerTableCellMode {
  case Time // Displays hour, minute, and optionally AM/PM designation depending on the locale setting (e.g. 6 | 53 | PM)
  case Date // Displays month, day, and year depending on the locale setting (e.g. November | 15 | 2007)
  case DateAndTime // Displays date, hour, minute, and optionally AM/PM designation depending on the locale setting (e.g. Wed Nov 15 | 6 | 53 | PM)
  
  var datePickerMode: UIDatePickerMode {
    switch self {
    case .Time: return .Time
    case .Date: return .Date
    case .DateAndTime: return .DateAndTime
    }
  }
}

class DatePickerTableCell<T: NSDate>: TableCellWithValue<NSDate>, UIDatePickerTableViewCellDelegate {
  
  let datePickerMode: DatePickerTableCellMode
  let minimumDate: NSDate?
  let maximumDate: NSDate?
  let height: UIPickerViewHeight
  
  var uiCell: UIDatePickerTableViewCell?

  init(value: NSDate, container: TableCellsContainer, datePickerMode: DatePickerTableCellMode, minimumDate: NSDate? = nil, maximumDate: NSDate? = nil, height: UIPickerViewHeight = .Medium) {
    self.datePickerMode = datePickerMode
    self.minimumDate = minimumDate
    self.maximumDate = maximumDate
    self.height = height
    super.init(value: value, container: container)
  }
 
  override func createUICell(tableView tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
    if uiCell == nil {
      uiCell = UIDatePickerTableViewCell()
    }
    
    uiCell!.delegate = self
    uiCell!.datePicker.datePickerMode = datePickerMode.datePickerMode
    uiCell!.datePicker.minimumDate = minimumDate
    uiCell!.datePicker.maximumDate = maximumDate
    updateUICell()
    return uiCell!
  }
  
  override func valueDidChange() {
    super.valueDidChange()
    updateUICell()
  }
  
  private func updateUICell() {
    if let uiCell = uiCell {
      uiCell.datePicker.date = value
    }
  }

  override func getRowHeight() -> CGFloat? {
    return height.rawValue
  }

  // MARK: UIDatePickerTableViewCellDelegate
  
  func datePickerValueDidChange(datePicker: UIDatePicker) {
    value = datePicker.date
    baseTableCell?.value = datePicker.date
  }

}
