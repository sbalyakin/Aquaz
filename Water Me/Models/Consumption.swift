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
  class func addEntity(#drink: Drink, amount: NSNumber, date: NSDate, managedObjectContext: NSManagedObjectContext, saveImmediately: Bool = true) -> Consumption {
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
