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
  
  class func getEntityName() -> String {
    return "ConsumptionRate"
  }
  
  class func fetchConsumptionRateForDate(date: NSDate) -> ConsumptionRate? {
    // Fetch consumption rate entity for the specified date
    let strictDatePredicate = NSPredicate(format: "date = %@", argumentArray: [date])
    let consumptionRateForStrictDate: ConsumptionRate? = ModelHelper.sharedInstance.fetchManagedObject(predicate: strictDatePredicate)
    
    if let consumptionRate = consumptionRateForStrictDate {
      return consumptionRate
    }
    
    // If there is no consumption rate entity exist for the specified date, search for consumption rate entity for the nearest sooner date
    let soonerDatePredicate = NSPredicate(format: "date < %@", argumentArray: [date])
    let soonerSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
    let consumptionRateForSoonerDate: ConsumptionRate? = ModelHelper.sharedInstance.fetchManagedObject(predicate: soonerDatePredicate, sortDescriptors: [soonerSortDescriptor])
    
    if let consumptionRate = consumptionRateForSoonerDate {
      return consumptionRate
    }
    
    // If there is no consumption rate entity exist for the sooner date, search for consumption rate entity for the nearest later date
    let laterDatePredicate = NSPredicate(format: "date > %@", argumentArray: [date])
    let laterSortDescriptor = NSSortDescriptor(key: "date", ascending: true)
    let consumptionRateForLaterDate: ConsumptionRate? = ModelHelper.sharedInstance.fetchManagedObject(predicate: laterDatePredicate, sortDescriptors: [laterSortDescriptor])
    
    if let consumptionRate = consumptionRateForSoonerDate {
      return consumptionRate
    }
    
    return nil
  }
  
  /// Adds a new consumption entity into Core Data
  class func addEntity(#date: NSDate,
                       baseRateAmount: NSNumber,
                       hotDateFraction: NSNumber,
                       highActivityFraction: NSNumber,
                       managedObjectContext: NSManagedObjectContext = ModelHelper.sharedInstance.managedObjectContext,
                       saveImmediately: Bool = true) -> ConsumptionRate {
    let consumptionRate = NSEntityDescription.insertNewObjectForEntityForName(getEntityName(), inManagedObjectContext: managedObjectContext) as ConsumptionRate
    consumptionRate.date = date
    consumptionRate.baseRateAmount = baseRateAmount
    consumptionRate.hotDayFraction = hotDateFraction
    consumptionRate.highActivityFraction = highActivityFraction
    
    if saveImmediately {
      var error: NSError? = nil
      if !managedObjectContext.save(&error) {
        NSLog("Failed to save new consumption rate for date \"\(date)\". Error: \(error!.localizedDescription)")
      }
    }
    
    return consumptionRate
  }

}
