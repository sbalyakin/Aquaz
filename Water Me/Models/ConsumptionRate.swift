//
//  ConsumptionRate.swift
//  Water Me
//
//  Created by Sergey Balyakin on 06.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

class ConsumptionRate: NSManagedObject, NamedEntity {
  
  /// Date of consumption rate entity
  @NSManaged var date: NSDate
  
  /// Base consumption rate in volume units (millilitres)
  @NSManaged var baseRateAmount: NSNumber
  
  /// Additional consumption rate for hot day in fraction of base consumption rate
  @NSManaged var hotDayFraction: NSNumber

  /// Additional consumption rate for high user activity in fraction of base consumption rate
  @NSManaged var highActivityFraction: NSNumber
  
  var amount: Double {
    return baseRateAmount.doubleValue * (1 + hotDayFraction.doubleValue + highActivityFraction.doubleValue)
  }
  
  class func getEntityName() -> String {
    return "ConsumptionRate"
  }
  
  class func fetchConsumptionRateForDate(date: NSDate) -> ConsumptionRate? {
    let adjustedDate = DateHelper.dateByClearingTime(ofDate: date)
    
    if let consumptionRate = fetchConsumptionRateStrictlyForDate(adjustedDate) {
      return consumptionRate
    }
    
    if let consumptionRate = fetchNearestConsumptionRateForDateEarlierThanDate(adjustedDate) {
      return consumptionRate
    }
    
    if let consumptionRate = fetchNearestConsumptionRateForDateLaterThanDate(adjustedDate) {
      return consumptionRate
    }
    
    assert(false)
    return nil
  }
  
  class func fetchConsumptionRateAmounts(beginDate beginDateRaw: NSDate, endDate endDateRaw: NSDate) -> [Double] {
    let beginDate = DateHelper.dateByClearingTime(ofDate: beginDateRaw)
    let endDate = DateHelper.dateByClearingTime(ofDate: endDateRaw)

    let consumptionRates = fetchConsumptionRatesForDateInterval(beginDate: beginDate, endDate: endDate)
    var earlierConsumptionRate = fetchNearestConsumptionRateForDateEarlierThanDate(beginDate)
    var laterConsumptionRate = fetchNearestConsumptionRateForDateLaterThanDate(endDate)
    
    var consumptionRateAmounts: [Double] = []
    var consumptionRateIndex = 0
    
    for var currentDay = beginDate; currentDay.isEarlierThan(endDate); currentDay = currentDay.getNextDay() {
      let consumptionRateAmount = findConsumptionRateForDate(currentDay,
        consumptionRates: consumptionRates,
        consumptionRateIndex: &consumptionRateIndex,
        earlierConsumptionRate: &earlierConsumptionRate,
        laterConsumptionRate: &laterConsumptionRate)

      consumptionRateAmounts.append(consumptionRateAmount)
    }
    
    return consumptionRateAmounts
  }
  
  class func fetchConsumptionRateAmountsGroupedByMonths(beginDate beginDateRaw: NSDate, endDate endDateRaw: NSDate) -> [Double] {
    let beginDate = DateHelper.dateByClearingTime(ofDate: beginDateRaw)
    let endDate = DateHelper.dateByClearingTime(ofDate: endDateRaw)
    
    let consumptionRates = fetchConsumptionRatesForDateInterval(beginDate: beginDate, endDate: endDate)
    var earlierConsumptionRate = fetchNearestConsumptionRateForDateEarlierThanDate(beginDate)
    var laterConsumptionRate = fetchNearestConsumptionRateForDateLaterThanDate(endDate)

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
  
  class func findConsumptionRateForDate(currentDay: NSDate, consumptionRates: [ConsumptionRate], inout consumptionRateIndex: Int, inout earlierConsumptionRate: ConsumptionRate?, inout laterConsumptionRate: ConsumptionRate?) -> Double {
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
  
  class func fetchConsumptionRateStrictlyForDate(date: NSDate) -> ConsumptionRate? {
    let predicate = NSPredicate(format: "date = %@", argumentArray: [date])
    return ModelHelper.sharedInstance.fetchManagedObject(predicate: predicate)
  }
  
  class func fetchNearestConsumptionRateForDateEarlierThanDate(date: NSDate) -> ConsumptionRate? {
    let predicate = NSPredicate(format: "date < %@", argumentArray: [date])
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
    return ModelHelper.sharedInstance.fetchManagedObject(predicate: predicate, sortDescriptors: [sortDescriptor])
  }
  
  class func fetchNearestConsumptionRateForDateLaterThanDate(date: NSDate) -> ConsumptionRate? {
    let predicate = NSPredicate(format: "date >= %@", argumentArray: [date])
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
    return ModelHelper.sharedInstance.fetchManagedObject(predicate: predicate, sortDescriptors: [sortDescriptor])
  }
  
  class func fetchConsumptionRatesForDateInterval(#beginDate: NSDate, endDate: NSDate) -> [ConsumptionRate] {
    let predicate = NSPredicate(format: "(date >= %@) AND (date < %@)", argumentArray: [beginDate, endDate])
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
    return ModelHelper.sharedInstance.fetchManagedObjects(predicate: predicate, sortDescriptors: [sortDescriptor])
  }
  
  /// Adds a new consumption entity into Core Data
  class func addEntity(#date: NSDate,
                       baseRateAmount: NSNumber,
                       hotDateFraction: NSNumber,
                       highActivityFraction: NSNumber,
                       managedObjectContext: NSManagedObjectContext = ModelHelper.sharedInstance.managedObjectContext,
                       saveImmediately: Bool = true) -> ConsumptionRate {
    let consumptionRate = NSEntityDescription.insertNewObjectForEntityForName(getEntityName(), inManagedObjectContext: managedObjectContext) as ConsumptionRate
    let adjustedDate = DateHelper.dateByClearingTime(ofDate: date)
    consumptionRate.date = adjustedDate
    consumptionRate.baseRateAmount = baseRateAmount
    consumptionRate.hotDayFraction = hotDateFraction
    consumptionRate.highActivityFraction = highActivityFraction
    
    if saveImmediately {
      var error: NSError? = nil
      if !managedObjectContext.save(&error) {
        NSLog("Failed to save new consumption rate for date \"\(adjustedDate)\". Error: \(error!.localizedDescription)")
      }
    }
    
    return consumptionRate
  }

}
