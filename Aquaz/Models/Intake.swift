//
//  Intake.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 07.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

public class Intake: NSManagedObject, NamedEntity {
  
  public static var entityName = "Intake"

  /// Amount of intake in millilitres
  @NSManaged public var amount: NSNumber
  
  /// Date of intake
  @NSManaged public var date: NSDate
  
  /// What drink was consumed
  @NSManaged public var drink: Drink
  
  /// Amount of pure water of the intake taking into account water percentage of the drink
  public var waterAmount: Double {
    return amount.doubleValue * drink.waterPercent.doubleValue
  }
  
  /// Adds a new intake's entity into Core Data
  public class func addEntity(#drink: Drink, amount: NSNumber, date: NSDate, managedObjectContext: NSManagedObjectContext?, saveImmediately: Bool = true) -> Intake? {
    if let managedObjectContext = managedObjectContext, let intake = LoggedActions.insertNewObjectForEntity(self, inManagedObjectContext: managedObjectContext) {
      intake.amount = amount
      intake.drink = drink
      intake.date = date

      if saveImmediately {
        var error: NSError?
        if !managedObjectContext.save(&error) {
          Logger.logError(Logger.Messages.failedToSaveManagedObjectContext, error: error)
          return nil
        }
      }

      return intake
    }
    
    assert(false)
    return nil
  }

  /// Deletes the intake from Core Data
  public func deleteEntity(saveImmediately: Bool = true) {
    if let managedObjectContext = managedObjectContext {
      managedObjectContext.deleteObject(self)
      
      if saveImmediately {
        var error: NSError?
        if !managedObjectContext.save(&error) {
          Logger.logError(Logger.Messages.failedToSaveManagedObjectContext, error: error)
        }
      }
    } else {
      assert(false)
    }
  }
  
  /// Fetches all intakes for the specified date interval (beginDate..<endDate)
  public class func fetchIntakes(#beginDate: NSDate, endDate: NSDate, managedObjectContext: NSManagedObjectContext?) -> [Intake] {
    let predicate = NSPredicate(format: "(date >= %@) AND (date < %@)", argumentArray: [beginDate, endDate])
    let descriptor = NSSortDescriptor(key: "date", ascending: true)
    return ModelHelper.fetchManagedObjects(managedObjectContext: managedObjectContext, predicate: predicate, sortDescriptors: [descriptor])
  }

  /// Fetches all intakes for a day taken from the specified date.
  /// Start of the day is inclusively started from 0:00 + specified offset in hours.
  /// End of the day is exclusive ended with 0:00 of the next day + specified offset in hours.
  public class func fetchIntakesForDay(date: NSDate, dayOffsetInHours: Int, managedObjectContext: NSManagedObjectContext?) -> [Intake] {
    let beginDate = DateHelper.dateBySettingHour(dayOffsetInHours, minute: 0, second: 0, ofDate: date)
    let endDate = DateHelper.addToDate(beginDate, years: 0, months: 0, days: 1)
    return fetchIntakes(beginDate: beginDate, endDate: endDate, managedObjectContext: managedObjectContext)
  }

  public enum GroupingCalendarUnit {
    case Day
    case Month
    
    func getCalendarUnit() -> NSCalendarUnit {
      switch self {
      case .Day  : return .CalendarUnitDay
      case .Month: return .CalendarUnitMonth
      }
    }
  }
  
  public enum AggregateFunction {
    case Average
    case Summary
  }
  
  /// Fetches water amounts (taking water percent of drinks into account)
  /// for specified time period (beginDate..<endDate) grouping results by specified calendar unit.
  /// It's also possible to specify aggregate function for grouping.
  /// Note: Average function calculates an average value taking into account ALL days in a specified calendar unit,
  /// not only days with intakes.
  public class func fetchGroupedWaterAmounts(beginDate beginDateRaw: NSDate,
                                             endDate endDateRaw: NSDate,
                                             dayOffsetInHours: Int,
                                             groupingUnit: GroupingCalendarUnit,
                                             aggregateFunction aggregateFunctionRaw: AggregateFunction,
                                             managedObjectContext: NSManagedObjectContext?) -> [Double] {
    let beginDate = DateHelper.dateBySettingHour(dayOffsetInHours, minute: 0, second: 0, ofDate: beginDateRaw)
    let endDate = DateHelper.dateBySettingHour(dayOffsetInHours, minute: 0, second: 0, ofDate: endDateRaw)
    
    if endDate.isEarlierThan(beginDate) {
      return []
    }
    
    let intakes = fetchIntakes(beginDate: beginDate, endDate: endDate, managedObjectContext: managedObjectContext)

    // It's just an optimization. An algorithm below already groups intakes by days, so calculating the average is useless
    let aggregateFunction: AggregateFunction = (groupingUnit == .Day) ? .Summary : aggregateFunctionRaw
    
    let deltaMonths = groupingUnit == .Month ? 1 : 0
    let deltaDays   = groupingUnit == .Day   ? 1 : 0
    
    let calendarUnit = groupingUnit.getCalendarUnit()
    let calendar = NSCalendar.currentCalendar()
    
    var groupedWaterAmounts: [Double] = []
    var nextDate: NSDate!
    var intakeIndex = 0
    var daysInCalendarUnit = 0
    
    while true {
      let currentDate = nextDate ?? beginDate
      
      if aggregateFunction == .Average {
        daysInCalendarUnit = calendar.rangeOfUnit(.CalendarUnitDay, inUnit: calendarUnit, forDate: currentDate).length
      }

      nextDate = DateHelper.addToDate(currentDate, years: 0, months: deltaMonths, days: deltaDays)
      
      if nextDate.isLaterThan(endDate) {
        break
      }

      var waterAmountForUnit: Double = 0

      for ; intakeIndex < intakes.count; intakeIndex++ {
        let intake = intakes[intakeIndex]
        
        if !intake.date.isEarlierThan(nextDate) {
          break
        }

        waterAmountForUnit += intake.waterAmount
      }
      
      if aggregateFunction == .Average {
        waterAmountForUnit /= Double(daysInCalendarUnit)
      }
      
      groupedWaterAmounts.append(waterAmountForUnit)
    }
    
    return groupedWaterAmounts
  }
  
}
