//
//  Consumption.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 07.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

class Consumption: NSManagedObject, NamedEntity {
  
  @NSManaged var amount: NSNumber
  @NSManaged var date: NSDate
  @NSManaged var drink: Drink
  
  var waterIntake: Double {
    return amount.doubleValue * drink.waterPercent.doubleValue
  }
  
  class func getEntityName() -> String {
    return "Consumption"
  }
  
  /// Adds a new consumption entity into Core Data
  class func addEntity(#drink: Drink, amount: NSNumber, date: NSDate, managedObjectContext: NSManagedObjectContext?, saveImmediately: Bool = true) -> Consumption? {
    if let managedObjectContext = managedObjectContext {
      let consumption = NSEntityDescription.insertNewObjectForEntityForName(getEntityName(), inManagedObjectContext: managedObjectContext) as! Consumption
      consumption.amount = amount
      consumption.drink = drink
      consumption.date = date

      if saveImmediately {
        var error: NSError?
        if !managedObjectContext.save(&error) {
          NSLog("Failed to add new consumption for drink \"\(drink.name)\". Error: \(error?.localizedDescription ?? String())")
          return nil
        }
      }

      return consumption
    } else {
      assert(false)
      return nil
    }
  }

  /// Fetches all consumptions for the specified date interval [date, toDate)
  class func fetchConsumptions(#beginDate: NSDate, endDate: NSDate, managedObjectContext: NSManagedObjectContext?) -> [Consumption] {
    let predicate = NSPredicate(format: "(date >= %@) AND (date < %@)", argumentArray: [beginDate, endDate])
    let descriptor = NSSortDescriptor(key: "date", ascending: true)
    return ModelHelper.fetchManagedObjects(managedObjectContext: managedObjectContext, predicate: predicate, sortDescriptors: [descriptor])
  }

  /// Fetches all consumptions for a day taken from the specified date.
  /// Start of the day is inclusively started from 0:00 + specified offset in hours.
  /// End of the day is exclusive ended with 0:00 of the next day + specified offset in hours.
  class func fetchConsumptionsForDay(date: NSDate, dayOffsetInHours: Int, managedObjectContext: NSManagedObjectContext?) -> [Consumption] {
    let beginDate = DateHelper.dateBySettingHour(dayOffsetInHours, minute: 0, second: 0, ofDate: date)
    let endDate = DateHelper.addToDate(beginDate, years: 0, months: 0, days: 1)
    return fetchConsumptions(beginDate: beginDate, endDate: endDate, managedObjectContext: managedObjectContext)
  }

  enum GroupingCalendarUnit {
    case Day, Month, Year
    
    func getCalendarUnit() -> NSCalendarUnit {
      switch self {
      case .Day  : return .CalendarUnitDay
      case .Month: return .CalendarUnitMonth
      case .Year : return .CalendarUnitYear
      }
    }
  }
  
  /// Fetches water intake for specified time period grouping results by specified calendar unit
  class func fetchGroupedWaterIntake(beginDate beginDateRaw: NSDate, endDate endDateRaw: NSDate, dayOffsetInHours: Int, groupingUnit: GroupingCalendarUnit, var computeAverageAmounts: Bool, managedObjectContext: NSManagedObjectContext?) -> [Double] {
    let beginDate = DateHelper.dateBySettingHour(dayOffsetInHours, minute: 0, second: 0, ofDate: beginDateRaw)
    let endDate = DateHelper.dateBySettingHour(dayOffsetInHours, minute: 0, second: 0, ofDate: endDateRaw)
    
    if endDate.compare(beginDate) == .OrderedAscending {
      return []
    }
    
    let consumptions = fetchConsumptions(beginDate: beginDate, endDate: endDate, managedObjectContext: managedObjectContext)

    // Skip useless grouping for days
    if groupingUnit == .Day {
      computeAverageAmounts = false
    }
    
    let deltaYears  = groupingUnit == .Year  ? 1 : 0
    let deltaMonths = groupingUnit == .Month ? 1 : 0
    let deltaDays   = groupingUnit == .Day   ? 1 : 0
    
    let calendarUnit = groupingUnit.getCalendarUnit()
    let calendar = NSCalendar.currentCalendar()
    
    var groupedWaterIntakes: [Double] = []
    var nextDate: NSDate!
    var consumptionIndex = 0
    var lastWaterIntake: Double = 0
    var daysInCalendarUnit = 0
    
    while true {
      let currentDate = (nextDate == nil) ? beginDate : nextDate
      
      if computeAverageAmounts {
        daysInCalendarUnit = calendar.rangeOfUnit(.CalendarUnitDay, inUnit: calendarUnit, forDate: currentDate).length
      }

      nextDate = DateHelper.addToDate(currentDate, years: deltaYears, months: deltaMonths, days: deltaDays)
      
      if nextDate.isLaterThan(endDate) {
        break
      }

      var waterIntakeForUnit: Double = 0

      for ; consumptionIndex < consumptions.count; consumptionIndex++ {
        let consumption = consumptions[consumptionIndex]
        let waterIntake = consumption.amount.doubleValue * consumption.drink.waterPercent.doubleValue
        
        if !consumption.date.isEarlierThan(nextDate) {
          break
        }
        
        waterIntakeForUnit += waterIntake
      }
      
      if computeAverageAmounts {
        waterIntakeForUnit /= Double(daysInCalendarUnit)
      }
      
      groupedWaterIntakes.append(waterIntakeForUnit)
    }
    
    return groupedWaterIntakes
  }
  
  /// Deletes the consumption from Core Data
  func deleteEntity(saveImmediately: Bool = true) {
    if let managedObjectContext = managedObjectContext {
      managedObjectContext.deleteObject(self)
      
      if saveImmediately {
        var error: NSError?
        if !managedObjectContext.save(&error) {
          NSLog("Failed to delete consumption. Error: \(error?.localizedDescription ?? String())")
        }
      }
    } else {
      assert(false)
    }
  }
  
}
