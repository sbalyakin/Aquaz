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

  private struct Strings {
    static let waterTitle   = NSLocalizedString("D:Water",   value: "Water",   comment: "Drink: Title for water")
    static let coffeeTitle  = NSLocalizedString("D:Coffee",  value: "Coffee",  comment: "Drink: Title for coffee")
    static let teaTitle     = NSLocalizedString("D:Tea",     value: "Tea",     comment: "Drink: Title for tea")
    static let sodaTitle    = NSLocalizedString("D:Soda",    value: "Soda",    comment: "Drink: Title for soda")
    static let juiceTitle   = NSLocalizedString("D:Juice",   value: "Juice",   comment: "Drink: Title for juice")
    static let milkTitle    = NSLocalizedString("D:Milk",    value: "Milk",    comment: "Drink: Title for milk")
    static let alcoholTitle = NSLocalizedString("D:Alcohol", value: "Alcohol", comment: "Drink: Title for alcohol")
    static let sportTitle   = NSLocalizedString("D:Sport",   value: "Sport",   comment: "Drink: Title for sport drink")
    static let energyTitle  = NSLocalizedString("D:Energy",  value: "Energy",  comment: "Drink: Title for energetic drink")
  }
  
  enum DrinkType: Int {
    case water = 0
    case coffee
    case tea
    case soda
    case juice
    case milk
    case alcohol
    case sport
    case energy
    
    var localizedName: String {
      switch self {
      case water:   return Strings.waterTitle
      case coffee:  return Strings.coffeeTitle
      case tea:     return Strings.teaTitle
      case soda:    return Strings.sodaTitle
      case juice:   return Strings.juiceTitle
      case milk:    return Strings.milkTitle
      case alcohol: return Strings.alcoholTitle
      case sport:   return Strings.sportTitle
      case energy:  return Strings.energyTitle
      }
    }
    
    static var count: Int {
      return energy.rawValue + 1
    }
  }
  
  var localizedName: String {
    if let drinkType = DrinkType(rawValue: index.integerValue) {
      return drinkType.localizedName
    } else {
      assert(false, "Unknown drink index")
      return name
    }
  }
  
  class func getEntityName() -> String {
    return "Drink"
  }
  
  class func getDrinksCount() -> Int {
    return DrinkType.count
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
      assert(false, "Failed to save new drink named \"\(name)\". Error: \(error!.localizedDescription)")
    }
    
    return drink
  }
  
  class func fetchDrinks() -> [Drink] {
    let descriptor = NSSortDescriptor(key: "index", ascending: true)
    return ModelHelper.sharedInstance.fetchManagedObjects(predicate: nil, sortDescriptors: [descriptor])
  }

}
