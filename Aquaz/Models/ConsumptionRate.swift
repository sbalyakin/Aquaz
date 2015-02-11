//
//  ConsumptionRate.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 06.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

public class ConsumptionRate: NSManagedObject, NamedEntity {
  
  public static var entityName = "ConsumptionRate"

  /// Date of consumption rate entity
  @NSManaged public var date: NSDate
  
  /// Base consumption rate in volume units (millilitres)
  @NSManaged public var baseRateAmount: NSNumber
  
  /// Additional consumption rate for hot day in fraction of base consumption rate
  @NSManaged public var hotDayFraction: NSNumber

  /// Additional consumption rate for high user activity in fraction of base consumption rate
  @NSManaged public var highActivityFraction: NSNumber
  
  public var amount: Double {
    return baseRateAmount.doubleValue * (1 + hotDayFraction.doubleValue + highActivityFraction.doubleValue)
  }
  
  class func fetchConsumptionRateForDate(date: NSDate, managedObjectContext: NSManagedObjectContext?) -> ConsumptionRate? {
    let adjustedDate = DateHelper.dateByClearingTime(ofDate: date)
    
    if let consumptionRate = fetchConsumptionRateStrictlyForDate(adjustedDate, managedObjectContext: managedObjectContext) {
      return consumptionRate
    }
    
    if let consumptionRate = fetchNearestConsumptionRateForDateEarlierThanDate(adjustedDate, managedObjectContext: managedObjectContext) {
      return consumptionRate
    }
    
    if let consumptionRate = fetchNearestConsumptionRateForDateLaterThanDate(adjustedDate, managedObjectContext: managedObjectContext) {
      return consumptionRate
    }
    
    assert(false)
    return nil
  }
  
  class func fetchConsumptionRateAmounts(beginDate beginDateRaw: NSDate, endDate endDateRaw: NSDate, managedObjectContext: NSManagedObjectContext?) -> [Double] {
    let beginDate = DateHelper.dateByClearingTime(ofDate: beginDateRaw)
    let endDate = DateHelper.dateByClearingTime(ofDate: endDateRaw)

    let consumptionRates = fetchConsumptionRatesForDateInterval(beginDate: beginDate, endDate: endDate, managedObjectContext: managedObjectContext)
    var earlierConsumptionRate = fetchNearestConsumptionRateForDateEarlierThanDate(beginDate, managedObjectContext: managedObjectContext)
    var laterConsumptionRate = fetchNearestConsumptionRateForDateLaterThanDate(endDate, managedObjectContext: managedObjectContext)
    
    var consumptionRateAmounts: [Double] = []
    var consumptionRateIndex = 0
    
    for var currentDay = beginDate; currentDay.isEarlierThan(endDate); currentDay = currentDay.getNextDay() {
      let consumptionRateAmount = findConsumptionRateForDate(currentDay,
        consumptionRates: consumptionRates,
        managedObjectContext: managedObjectContext,
        consumptionRateIndex: &consumptionRateIndex,
        earlierConsumptionRate: &earlierConsumptionRate,
        laterConsumptionRate: &laterConsumptionRate)
      
      consumptionRateAmounts.append(consumptionRateAmount)
    }
    
    return consumptionRateAmounts
  }
  
  class func fetchConsumptionRateAmountsGroupedByMonths(beginDate beginDateRaw: NSDate, endDate endDateRaw: NSDate, managedObjectContext: NSManagedObjectContext?) -> [Double] {
    let beginDate = DateHelper.dateByClearingTime(ofDate: beginDateRaw)
    let endDate = DateHelper.dateByClearingTime(ofDate: endDateRaw)
    
    let consumptionRates = fetchConsumptionRatesForDateInterval(beginDate: beginDate, endDate: endDate, managedObjectContext: managedObjectContext)
    var earlierConsumptionRate = fetchNearestConsumptionRateForDateEarlierThanDate(beginDate, managedObjectContext: managedObjectContext)
    var laterConsumptionRate = fetchNearestConsumptionRateForDateLaterThanDate(endDate, managedObjectContext: managedObjectContext)

    let calendar = NSCalendar.currentCalendar()

    var consumptionRateAmounts: [Double] = []
    var consumptionRateIndex = 0
    var daysInMonth: Int!
    var processedDaysCount = 0
    var overallConsumptionRate: Double = 0

    let beginDayComponents = calendar.components(.CalendarUnitDay, fromDate: beginDate)
    var currentDayIndex = beginDayComponents.day

    for var currentDay = beginDate; currentDay.isEarlierThan(endDate); currentDay = currentDay.getNextDay() {
      if daysInMonth == nil {
        daysInMonth = calendar.rangeOfUnit(.CalendarUnitDay, inUnit: .CalendarUnitMonth, forDate: currentDay).length
      }

      let consumptionRateAmount = findConsumptionRateForDate(currentDay,
        consumptionRates: consumptionRates,
        managedObjectContext: managedObjectContext,
        consumptionRateIndex: &consumptionRateIndex,
        earlierConsumptionRate: &earlierConsumptionRate,
        laterConsumptionRate: &laterConsumptionRate)

      overallConsumptionRate += consumptionRateAmount
      processedDaysCount++
      currentDayIndex++
      
      if currentDayIndex > daysInMonth {
        let averageConsumptionRate = overallConsumptionRate / Double(processedDaysCount)
        consumptionRateAmounts.append(averageConsumptionRate)

        overallConsumptionRate = 0
        currentDayIndex = 1
        processedDaysCount = 0
        daysInMonth = nil
      }
    }
    
    if processedDaysCount > 0 {
      let averageConsumptionRate = overallConsumptionRate / Double(processedDaysCount)
      consumptionRateAmounts.append(averageConsumptionRate)
    }
  
    return consumptionRateAmounts
  }
  
  class func findConsumptionRateForDate(currentDay: NSDate, consumptionRates: [ConsumptionRate], managedObjectContext: NSManagedObjectContext?, inout consumptionRateIndex: Int, inout earlierConsumptionRate: ConsumptionRate?, inout laterConsumptionRate: ConsumptionRate?) -> Double {
    var amount: Double!
    
    // Looking for a consumption rate for the current day in fetched rates
    if consumptionRateIndex < consumptionRates.count {
      let consumptionRate = consumptionRates[consumptionRateIndex]
      let consumptionRateDate = consumptionRate.date
      
      switch currentDay.compare(consumptionRateDate) {
      case .OrderedSame:
        // Use computed amount (taking into account high activity etc.)
        // only for a consumption rate entity strictly related to the current day
        amount = consumptionRate.amount
        earlierConsumptionRate = consumptionRate
        consumptionRateIndex++
        
      case .OrderedAscending: // current consumption rate is later than current day
        laterConsumptionRate = consumptionRate
        
      case .OrderedDescending: // unreal case
        assert(false, "It's a logical error")
        earlierConsumptionRate = consumptionRate
      }
    }
    
    if amount == nil {
      if let earlierConsumptionRate = earlierConsumptionRate {
        amount = earlierConsumptionRate.baseRateAmount.doubleValue
      } else if let laterConsumptionRate = laterConsumptionRate {
        amount = laterConsumptionRate.baseRateAmount.doubleValue
      } else { // unreal case
        assert(false, "It's a logical error")
        amount = Settings.sharedInstance.userDailyWaterIntake.value
      }
    }

    return amount
  }
  
  class func fetchConsumptionRateStrictlyForDate(date: NSDate, managedObjectContext: NSManagedObjectContext?) -> ConsumptionRate? {
    let predicate = NSPredicate(format: "date = %@", argumentArray: [date])
    return ModelHelper.fetchManagedObject(managedObjectContext: managedObjectContext, predicate: predicate)
  }
  
  class func fetchNearestConsumptionRateForDateEarlierThanDate(date: NSDate, managedObjectContext: NSManagedObjectContext?) -> ConsumptionRate? {
    let predicate = NSPredicate(format: "date < %@", argumentArray: [date])
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
    return ModelHelper.fetchManagedObject(managedObjectContext: managedObjectContext, predicate: predicate, sortDescriptors: [sortDescriptor])
  }
  
  class func fetchNearestConsumptionRateForDateLaterThanDate(date: NSDate, managedObjectContext: NSManagedObjectContext?) -> ConsumptionRate? {
    let predicate = NSPredicate(format: "date >= %@", argumentArray: [date])
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
    return ModelHelper.fetchManagedObject(managedObjectContext: managedObjectContext, predicate: predicate, sortDescriptors: [sortDescriptor])
  }
  
  class func fetchConsumptionRatesForDateInterval(#beginDate: NSDate, endDate: NSDate, managedObjectContext: NSManagedObjectContext?) -> [ConsumptionRate] {
    let predicate = NSPredicate(format: "(date >= %@) AND (date < %@)", argumentArray: [beginDate, endDate])
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
    return ModelHelper.fetchManagedObjects(managedObjectContext: managedObjectContext, predicate: predicate, sortDescriptors: [sortDescriptor])
  }
  
  /// Adds a new consumption entity into Core Data
  class func addEntity(#date: NSDate,
                       baseRateAmount: NSNumber,
                       hotDateFraction: NSNumber,
                       highActivityFraction: NSNumber,
                       managedObjectContext: NSManagedObjectContext?,
                       saveImmediately: Bool = true) -> ConsumptionRate? {
    if let managedObjectContext = managedObjectContext {
      if let consumptionRate = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: managedObjectContext) as? ConsumptionRate {
        let adjustedDate = DateHelper.dateByClearingTime(ofDate: date)
        consumptionRate.date = adjustedDate
        consumptionRate.baseRateAmount = baseRateAmount
        consumptionRate.hotDayFraction = hotDateFraction
        consumptionRate.highActivityFraction = highActivityFraction
        
        if saveImmediately {
          var error: NSError?
          if !managedObjectContext.save(&error) {
            NSLog("Failed to save new consumption rate for date \"\(adjustedDate)\". Error: \(error?.localizedDescription ?? String())")
            return nil
          }
        }
        
        return consumptionRate
      } else {
        assert(false)
        return nil
      }
    } else {
      assert(false)
      return nil
    }
  }

}
