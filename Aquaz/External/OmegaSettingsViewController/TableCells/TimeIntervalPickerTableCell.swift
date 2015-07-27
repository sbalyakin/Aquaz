//
//  TimeIntervalPickerTableCell.swift
//  Aquaz
//
//  Created by Admin on 05.03.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

// This class is used to add possibility to use TimeIntervalPickerTableCell as non-generic class
class TimeIntervalPickerTableCellHelper {
}

struct TimeIntervalPickerTableCellComponent {
  let calendarUnit: NSCalendarUnit
  let minValue: Int
  let maxValue: Int
  let step: Int
  let title: String
  let width: CGFloat?
}

class TimeIntervalPickerTableCell<T: TimeIntervalPickerTableCellHelper>: MultiPickerTableCell<NSTimeInterval, IntCollection> {
  
  let timeComponents: [TimeIntervalPickerTableCellComponent]
  
  init(value: NSTimeInterval, timeComponents: [TimeIntervalPickerTableCellComponent], container: TableCellsContainer, height: UIPickerViewHeight = .Medium) {
    self.timeComponents = timeComponents
    let components = TimeIntervalPickerTableCell.generateComponentsFromTimeComponents(timeComponents)
    super.init(value: value, components: components, container: container, height: height)
    selectionToValueFunction = convertSelectedRowsToTimeInterval
    valueToSelectionFunction = convertTimeIntervalToSelectedRows
  }
  
  private class func generateComponentsFromTimeComponents(timeComponents: [TimeIntervalPickerTableCellComponent]) -> [Component] {
    var components = [Component]()
    for timeComponent in timeComponents {
      let collection = IntCollection(minimumValue: timeComponent.minValue, maximumValue: timeComponent.maxValue + 1, step: timeComponent.step)
      let component: Component = (title: timeComponent.title, width: timeComponent.width, collection: collection)
      components += [component]
    }
    return components
  }
  
  private func convertSelectedRowsToTimeInterval(selectedRows: [Int]) -> NSTimeInterval {
    assert(selectedRows.count == timeComponents.count)
    
    var timeInterval: NSTimeInterval = 0
    for (index, timeComponent) in enumerate(timeComponents) {
      let duration = getDurationForCalendarUnit(timeComponent.calendarUnit)
      let row = selectedRows[index]
      timeInterval += duration * NSTimeInterval(timeComponent.minValue + timeComponent.step * row)
    }
    
    return timeInterval
  }
  
  private func convertTimeIntervalToSelectedRows(timeInterval: NSTimeInterval) -> [Int] {
    var selectedRows = [Int]()
    
    for timeComponent in timeComponents {
      let duration = getDurationForCalendarUnit(timeComponent.calendarUnit)
      let unitMaximum = getMaximumForCalendarUnit(timeComponent.calendarUnit)
      var value = Int(timeInterval / duration) % unitMaximum
      value = min(timeComponent.maxValue, value)
      value = max(timeComponent.minValue, value)
      let row = (value - timeComponent.minValue) / timeComponent.step
      selectedRows += [row]
    }
  
    return selectedRows
  }
  
  private func getDurationForCalendarUnit(calendarUnit: NSCalendarUnit) -> NSTimeInterval {
    switch calendarUnit {
    case NSCalendarUnit.CalendarUnitSecond: return 1
    case NSCalendarUnit.CalendarUnitMinute: return 60
    case NSCalendarUnit.CalendarUnitHour  : return 60 * 60
    case NSCalendarUnit.CalendarUnitDay   : return 24 * 60 * 60
    default: return 0
    }
  }
  
  private func getMaximumForCalendarUnit(calendarUnit: NSCalendarUnit) -> Int {
    switch calendarUnit {
    case NSCalendarUnit.CalendarUnitSecond: return 60
    case NSCalendarUnit.CalendarUnitMinute: return 60
    case NSCalendarUnit.CalendarUnitHour  : return 24
    case NSCalendarUnit.CalendarUnitDay   : return Int.max - 1
    default: return 0
    }
  }
  
}