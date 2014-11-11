//
//  Drink.swift
//  Water Me
//
//  Created by Sergey Balyakin on 07.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

class Drink: NSManagedObject, NamedEntity {
  
  @NSManaged var index: NSNumber
  @NSManaged var color: AnyObject
  @NSManaged var name: String
  @NSManaged var waterPercent: NSNumber
  @NSManaged var consumptions: NSSet
  @NSManaged var recentAmount: RecentAmount
  
  class func getEntityName() -> String {
    return "Drink"
  }
  
  class func getDrinkByIndex(index: Int) -> Drink? {
    // Use the cache to store previously used drink objects
    struct Cache {
      static var drinks: [Int: Drink] = [:]
    }
    
    // Try to search for the drink in the cache
    if let drink = Cache.drinks[index] {
      return drink
    }
    
    // Fetch the drink from Core Data
    let predicate = NSPredicate(format: "%K = %@", argumentArray: ["index", index])
    let drink: Drink? = ModelHelper.sharedInstance.fetchManagedObject(predicate: predicate)
    
    assert(drink != nil, "Requested drink with index \(index) is not found")
    if drink == nil {
      NSLog("Requested drink with index \(index) is not found")
    } else {
      // Put the drink into the cache
      Cache.drinks[index] = drink
    }
    
    return drink
  }
  
  class func addEntity(#index: Int, name: String, waterPercent: NSNumber, color: UIColor, recentAmount amount: NSNumber, managedObjectContext: NSManagedObjectContext) -> Drink {
    let drink = NSEntityDescription.insertNewObjectForEntityForName("Drink", inManagedObjectContext: managedObjectContext) as Drink
    drink.index = index
    drink.name = name
    drink.waterPercent = waterPercent
    drink.color = color
    
    let recentAmount = NSEntityDescription.insertNewObjectForEntityForName("RecentAmount", inManagedObjectContext: managedObjectContext) as RecentAmount
    recentAmount.drink = drink
    recentAmount.amount = amount
    
    var error: NSError? = nil
    if !managedObjectContext.save(&error) {
      assert(false, "Failed to save new drink named \"\(name)\"")
    }
    
    return drink
  }

}
