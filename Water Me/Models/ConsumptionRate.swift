//
//  ConsumptionRate.swift
//  Water Me
//
//  Created by Sergey Balyakin on 06.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

private extension NSDate {
  func isLaterThan(date: NSDate) -> Bool {
    return date.compare(self) == .OrderedAscending
  }

  func isEarlierThan(date: NSDate) -> Bool {
    return date.compare(self) == .OrderedDescending
  }
  
  func getNextDay() -> NSDate {
    return DateHelper.addToDate(self, years: 0, months: 0, days: 1)
  }
}

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
  
  class func fetchConsumptionRateAmountsForDateInterval(beginDate beginDateRaw: NSDate, endDate endDateRaw: NSDate) -> [Double] {
    let beginDate = DateHelper.dateByClearingTime(ofDate: beginDateRaw)
    let endDate = DateHelper.dateByClearingTime(ofDate: endDateRaw)

    let consumptionRates = fetchConsumptionRatesForDateInterval(beginDate: beginDate, endDate: endDate)
    var consumptionRateForEarlierDate = fetchNearestConsumptionRateForDateEarlierThanDate(beginDate)
    var consumptionRateForLaterDate = fetchNearestConsumptionRateForDateLaterThanDate(endDate)
    
    var consumptionRateAmounts: [Double] = []
    var index = 0
    
    for var currentDay = beginDate; currentDay.isEarlierThan(endDate); currentDay = currentDay.getNextDay() {
      var consumptionRateAmount: Double!

      // Looking for a consumption rate for the current day in fetched rates
      if index < consumptionRates.count {
        let consumptionRate = consumptionRates[index]
        
        switch currentDay.compare(consumptionRate.date) {
        case .OrderedSame:
          // Use computed amount (taking into account high activity etc.)
          // only for a consumption rate entity strictly related to the current day
          consumptionRateAmount = consumptionRate.amount
          consumptionRateForEarlierDate = consumptionRate
          index++
          
        case .OrderedAscending: // current consumption rate is later than current day
          consumptionRateForLaterDate = consumptionRate
          
        case .OrderedDescending: // unreal case
          assert(false, "It's a logical error")
          consumptionRateForEarlierDate = consumptionRate
        }
      }
      
      if consumptionRateAmount == nil {
        if let earlierConsumptionRate = consumptionRateForEarlierDate {
          consumptionRateAmount = earlierConsumptionRate.baseRateAmount.doubleValue
        } else if let laterConsumptionRate = consumptionRateForLaterDate {
          consumptionRateAmount = laterConsumptionRate.baseRateAmount.doubleValue
        } else { // unreal case
          assert(false, "It's a logical error")
          consumptionRateAmount = Settings.sharedInstance.userDailyWaterIntake.value
        }
      }
      
      consumptionRateAmounts.append(consumptionRateAmount)
    }
    
    return consumptionRateAmounts
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
