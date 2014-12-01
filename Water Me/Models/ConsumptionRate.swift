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
    
    // Fetch consumption rate entity for the specified date
    let strictDatePredicate = NSPredicate(format: "date = %@", argumentArray: [adjustedDate])
    let consumptionRateForStrictDate: ConsumptionRate? = ModelHelper.sharedInstance.fetchManagedObject(predicate: strictDatePredicate)
    
    if let consumptionRate = consumptionRateForStrictDate {
      return consumptionRate
    }
    
    // If there is no consumption rate entity exist for the specified date, search for consumption rate entity for the nearest sooner date
    let soonerDatePredicate = NSPredicate(format: "date < %@", argumentArray: [adjustedDate])
    let soonerSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
    let consumptionRateForSoonerDate: ConsumptionRate? = ModelHelper.sharedInstance.fetchManagedObject(predicate: soonerDatePredicate, sortDescriptors: [soonerSortDescriptor])
    
    if let consumptionRate = consumptionRateForSoonerDate {
      return consumptionRate
    }
    
    // If there is no consumption rate entity exist for the sooner date, search for consumption rate entity for the nearest later date
    let laterDatePredicate = NSPredicate(format: "date > %@", argumentArray: [adjustedDate])
    let laterSortDescriptor = NSSortDescriptor(key: "date", ascending: true)
    let consumptionRateForLaterDate: ConsumptionRate? = ModelHelper.sharedInstance.fetchManagedObject(predicate: laterDatePredicate, sortDescriptors: [laterSortDescriptor])
    
    if let consumptionRate = consumptionRateForLaterDate {
      return consumptionRate
    }
    
    assert(false)
    return nil
  }
  
  class func fetchConsumptionRateAmountsForDateInterval(beginDate beginDateRaw: NSDate, endDate endDateRaw: NSDate) -> [Double] {
    let beginDate = DateHelper.dateByClearingTime(ofDate: beginDateRaw)
    let endDate = DateHelper.dateByClearingTime(ofDate: endDateRaw)

    // Fetch consumptions rate for the specified date interval
    let dateIntervalPredicate = NSPredicate(format: "(date >= %@) AND (date < %@)", argumentArray: [beginDate, endDate])
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
    let consumptionRates: [ConsumptionRate]? = ModelHelper.sharedInstance.fetchManagedObjects(predicate: dateIntervalPredicate, sortDescriptors: [sortDescriptor])

    // Fetch consumption rate for the nearest sooner date
    let soonerDatePredicate = NSPredicate(format: "date < %@", argumentArray: [beginDate])
    let soonerSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
    let consumptionRateForSoonerDate: ConsumptionRate? = ModelHelper.sharedInstance.fetchManagedObject(predicate: soonerDatePredicate, sortDescriptors: [soonerSortDescriptor])
    
    // Fetch consumption rate entity for the nearest later date
    let laterDatePredicate = NSPredicate(format: "date >= %@", argumentArray: [endDate])
    let laterSortDescriptor = NSSortDescriptor(key: "date", ascending: true)
    let consumptionRateForLaterDate: ConsumptionRate? = ModelHelper.sharedInstance.fetchManagedObject(predicate: laterDatePredicate, sortDescriptors: [laterSortDescriptor])
    
    var consumptionRateAmounts: [Double] = []
    var currentDay: NSDate!
    var consumptionRateIndex = 0
    var previousConsumptionRateAmount: Double!
    
    while true {
      currentDay = currentDay == nil ? beginDate : DateHelper.addToDate(currentDay, years: 0, months: 0, days: 1)
      
      if endDate.compare(currentDay) == .OrderedAscending {
        break
      }

      var consumptionRateAmount: Double!

      if let consumptionRates = consumptionRates {
        consumptionRatesFor: for ; consumptionRateIndex < consumptionRates.count; consumptionRateIndex++ {
          let consumptionRate = consumptionRates[consumptionRateIndex]
          
          switch currentDay.compare(consumptionRate.date) {
          case .OrderedSame:
            consumptionRateAmount = consumptionRate.amount
            previousConsumptionRateAmount = consumptionRate.baseRateAmount.doubleValue
            consumptionRateIndex++
            break consumptionRatesFor
            
          case .OrderedAscending:
            if let consumptionRate = consumptionRateForSoonerDate {
              consumptionRateAmount = consumptionRate.baseRateAmount.doubleValue
              previousConsumptionRateAmount = consumptionRate.baseRateAmount.doubleValue
            } else {
              consumptionRateAmount = consumptionRate.baseRateAmount.doubleValue
              previousConsumptionRateAmount = consumptionRate.baseRateAmount.doubleValue
              break consumptionRatesFor
            }
            
          case .OrderedDescending:
            assert(false)
          }
        }
      }
      
      if consumptionRateAmount == nil {
        if previousConsumptionRateAmount != nil {
          consumptionRateAmount = previousConsumptionRateAmount
        } else {
          if let consumptionRate = consumptionRateForSoonerDate {
            consumptionRateAmount = consumptionRate.baseRateAmount.doubleValue
            previousConsumptionRateAmount = consumptionRate.baseRateAmount.doubleValue
          } else if let consumptionRate = consumptionRateForLaterDate {
            consumptionRateAmount = consumptionRate.baseRateAmount.doubleValue
            previousConsumptionRateAmount = consumptionRate.baseRateAmount.doubleValue
          } else {
            assert(false)
            consumptionRateAmount = Settings.sharedInstance.userDailyWaterIntake.value
            previousConsumptionRateAmount = consumptionRateAmount
          }
        }
      }
      
      consumptionRateAmounts.append(consumptionRateAmount)
    }
    
    return consumptionRateAmounts
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
