//
//  TimeIntervalPickerTableCell.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 05.03.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

// This class is used to add possibility to use TimeIntervalPickerTableCell as non-generic class
class TimeIntervalPickerTableCellHelper {
}

struct TimeIntervalPickerTableCellComponent {
  let calendarComponents: Calendar.Component
  let minValue: Int
  let maxValue: Int
  let step: Int
  let title: String
  let width: CGFloat?
}

class TimeIntervalPickerTableCell: MultiPickerTableCell<TimeInterval, IntCollection> {
  
  let timeComponents: [TimeIntervalPickerTableCellComponent]
  
  init(value: TimeInterval, timeComponents: [TimeIntervalPickerTableCellComponent], container: TableCellsContainer, height: UIPickerViewHeight = .medium) {
    self.timeComponents = timeComponents
    let components = TimeIntervalPickerTableCell.generateComponentsFromTimeComponents(timeComponents)
    super.init(value: value, components: components, container: container, height: height)
    selectionToValueFunction = { [weak self] in return self?.convertSelectedRowsToTimeInterval($0) ?? 0 }
    valueToSelectionFunction = { [weak self] in return self?.convertTimeIntervalToSelectedRows($0) ?? [] }
  }
  
  fileprivate class func generateComponentsFromTimeComponents(_ timeComponents: [TimeIntervalPickerTableCellComponent]) -> [Component] {
    var components = [Component]()
    for timeComponent in timeComponents {
      let collection = IntCollection(minimumValue: timeComponent.minValue, maximumValue: timeComponent.maxValue + 1, step: timeComponent.step)
      let component: Component = (title: timeComponent.title, width: timeComponent.width, collection: collection)
      components += [component]
    }
    return components
  }
  
  fileprivate func convertSelectedRowsToTimeInterval(_ selectedRows: [Int]) -> TimeInterval {
    assert(selectedRows.count == timeComponents.count)
    
    var timeInterval: TimeInterval = 0
    for (index, timeComponent) in timeComponents.enumerated() {
      let duration = getDurationForCalendarComponent(timeComponent.calendarComponents)
      let row = selectedRows[index]
      timeInterval += duration * TimeInterval(timeComponent.minValue + timeComponent.step * row)
    }
    
    return timeInterval
  }
  
  fileprivate func convertTimeIntervalToSelectedRows(_ timeInterval: TimeInterval) -> [Int] {
    var selectedRows = [Int]()
    
    for timeComponent in timeComponents {
      let duration = getDurationForCalendarComponent(timeComponent.calendarComponents)
      let unitMaximum = getMaximumForCalendarComponent(timeComponent.calendarComponents)
      var value = Int(timeInterval / duration) % unitMaximum
      value = min(timeComponent.maxValue, value)
      value = max(timeComponent.minValue, value)
      let row = (value - timeComponent.minValue) / timeComponent.step
      selectedRows += [row]
    }
  
    return selectedRows
  }
  
  fileprivate func getDurationForCalendarComponent(_ component: Calendar.Component) -> TimeInterval {
    switch component {
    case .second: return 1
    case .minute: return 60
    case .hour  : return 60 * 60
    case .day   : return 24 * 60 * 60
    default: return 0
    }
  }
  
  fileprivate func getMaximumForCalendarComponent(_ component: Calendar.Component) -> Int {
    switch component {
    case .second: return 60
    case .minute: return 60
    case .hour  : return 24
    case .day   : return Int.max - 1
    default: return 0
    }
  }
  
}
