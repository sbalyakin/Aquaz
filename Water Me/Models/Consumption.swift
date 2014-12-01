//
//  Consumption.swift
//  Water Me
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
  class func addEntity(#drink: Drink, amount: NSNumber, date: NSDate, managedObjectContext: NSManagedObjectContext = ModelHelper.sharedInstance.managedObjectContext, saveImmediately: Bool = true) -> Consumption {
    let consumption = NSEntityDescription.insertNewObjectForEntityForName(getEntityName(), inManagedObjectContext: managedObjectContext) as Consumption
    consumption.amount = amount
    consumption.drink = drink
    consumption.date = date

    if saveImmediately {
      var error: NSError? = nil
      if !managedObjectContext.save(&error) {
        NSLog("Failed to add new consumption for drink \"\(drink.name)\". Error: \(error!.localizedDescription)")
      }
    }

    return consumption
  }

  /// Fetches all consumptions for the specified date interval [date, toDate)
  class func fetchConsumptions(#beginDate: NSDate, endDate: NSDate) -> [Consumption] {
    let predicate = NSPredicate(format: "(date >= %@) AND (date < %@)", argumentArray: [beginDate, endDate])
    let descriptor = NSSortDescriptor(key: "date", ascending: true)
    let rawConsumptions: [Consumption]? = ModelHelper.sharedInstance.fetchManagedObjects(predicate: predicate, sortDescriptors: [descriptor])
    
    if let consumptions = rawConsumptions {
      return consumptions
    }
    
    return []
  }

  /// Fetches all consumptions for a day taken from the specified date.
  /// Start of the day is inclusively started from 0:00 + specified offset in hours.
  /// End of the day is exclusive ended with 0:00 of the next day + specified offset in hours.
  class func fetchConsumptionsForDay(date: NSDate, dayOffsetInHours: Int) -> [Consumption] {
    let beginDate = DateHelper.dateBySettingHour(dayOffsetInHours, minute: 0, second: 0, ofDate: date)
    let endDate = DateHelper.addToDate(beginDate, years: 0, months: 0, days: 1)
    return fetchConsumptions(beginDate: beginDate, endDate: endDate)
  }

  enum GroupingCalendarUnit {
    case Day, Month, Year
  }
  
  /// Fetches water intake for specified time period grouping results by specified calendar unit
  class func fetchGroupedWaterIntake(beginDate beginDateRaw: NSDate, endDate endDateRaw: NSDate, dayOffsetInHours: Int, groupingUnit: GroupingCalendarUnit) -> [Double] {
    let beginDate = DateHelper.dateBySettingHour(dayOffsetInHours, minute: 0, second: 0, ofDate: beginDateRaw)
    let endDate = DateHelper.dateBySettingHour(dayOffsetInHours, minute: 0, second: 0, ofDate: endDateRaw)
    
    if endDate.compare(beginDate) == .OrderedAscending {
      return []
    }
    
    let consumptions = fetchConsumptions(beginDate: beginDate, endDate: endDate)
    
    let deltaYears  = groupingUnit == .Year  ? 1 : 0
    let deltaMonths = groupingUnit == .Month ? 1 : 0
    let deltaDays   = groupingUnit == .Day   ? 1 : 0
    
    var groupedWaterIntakes: [Double] = []
    var startOfNextDay: NSDate!
    var consumptionIndex = 0
    var lastWaterIntake: Double = 0
    
    while true {
      startOfNextDay = DateHelper.addToDate(startOfNextDay == nil ? beginDate : startOfNextDay, years: deltaYears, months: deltaMonths, days: deltaDays)
      
      if endDate.compare(startOfNextDay) == .OrderedAscending {
        break
      }

      var waterIntakeForUnit: Double = lastWaterIntake
      lastWaterIntake = 0

      for ; consumptionIndex < consumptions.count; consumptionIndex++ {
        let consumption = consumptions[consumptionIndex]
        let waterIntake = consumption.amount.doubleValue * consumption.drink.waterPercent.doubleValue
        
        if startOfNextDay.compare(consumption.date) == .OrderedDescending {
          waterIntakeForUnit += waterIntake
        } else {
          consumptionIndex++
          // Remember current water intake in order to take it into account on the next day iteration
          lastWaterIntake = waterIntake
          break
        }
      }
      
      groupedWaterIntakes.append(waterIntakeForUnit)
    }
    
    return groupedWaterIntakes
  }
  
  /// Deletes the consumption from Core Data
  func deleteEntity(saveImmediately: Bool = true) {
    managedObjectContext!.deleteObject(self)
    
    if saveImmediately {
      var error: NSError? = nil
      if !managedObjectContext!.save(&error) {
        NSLog("Failed to delete consumption. Error: \(error!.localizedDescription)")
      }
    }
  }
  
}
