//
//  DatePickerTableCell.swift
//  OmegaSettingsViewController
//
//  Created by Sergey Balyakin on 06.03.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

enum DatePickerTableCellMode {
  case time // Displays hour, minute, and optionally AM/PM designation depending on the locale setting (e.g. 6 | 53 | PM)
  case date // Displays month, day, and year depending on the locale setting (e.g. November | 15 | 2007)
  case dateAndTime // Displays date, hour, minute, and optionally AM/PM designation depending on the locale setting (e.g. Wed Nov 15 | 6 | 53 | PM)
  
  var datePickerMode: UIDatePicker.Mode {
    switch self {
    case .time: return .time
    case .date: return .date
    case .dateAndTime: return .dateAndTime
    }
  }
}

class DatePickerTableCell<T: NSDate>: TableCellWithValue<Date>, UIDatePickerTableViewCellDelegate {
  
  let datePickerMode: DatePickerTableCellMode
  let minimumDate: Date?
  let maximumDate: Date?
  let height: UIPickerViewHeight
  
  var uiCell: UIDatePickerTableViewCell?

  init(value: Date, container: TableCellsContainer, datePickerMode: DatePickerTableCellMode, minimumDate: Date? = nil, maximumDate: Date? = nil, height: UIPickerViewHeight = .medium) {
    self.datePickerMode = datePickerMode
    self.minimumDate = minimumDate
    self.maximumDate = maximumDate
    self.height = height
    super.init(value: value, container: container)
  }
 
  override func createUICell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
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
  
  fileprivate func updateUICell() {
    if let uiCell = uiCell {
      uiCell.datePicker.date = value
    }
  }

  override func getRowHeight() -> CGFloat? {
    return height.rawValue
  }

  // MARK: UIDatePickerTableViewCellDelegate
  
  func datePickerValueDidChange(_ datePicker: UIDatePicker) {
    value = datePicker.date
    baseTableCell?.value = datePicker.date
  }

}
