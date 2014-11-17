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

  // Fetches all consumptions for the specified day (from 0:00 to 23:59:59 )
  class func fetchConsumptionsForDay(date: NSDate) -> [Consumption] {
    let beginDate = DateHelper.dateBySettingHour(0, minute: 0, second: 0, ofDate: date)
    let endDate = DateHelper.addToDate(beginDate, years: 0, months: 0, days: 1)
    
    // Fetch all consumptions for the specified date interval
    let predicate = NSPredicate(format: "(date >= %@) AND (date < %@)", argumentArray: [beginDate, endDate])
    let descriptor = NSSortDescriptor(key: "date", ascending: true)
    let rawConsumptions: [Consumption]? = ModelHelper.sharedInstance.fetchManagedObjects(predicate: predicate, sortDescriptors: [descriptor])
    
    if let consumptions = rawConsumptions {
      return consumptions
    }
    
    return []
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
