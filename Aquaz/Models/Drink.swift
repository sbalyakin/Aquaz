//
//  Drink.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 07.10.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc(Drink)
class Drink: CodingManagedObject, NamedEntity {

  typealias EntityType = Drink

  // MARK: Properties
  
  static var entityName = "Drink"
  
  @NSManaged var index: NSNumber
  @NSManaged var name: String
  @NSManaged var hydrationFactor: Double
  @NSManaged var dehydrationFactor: Double
  @NSManaged var intakes: NSSet
  @NSManaged var recentAmount: RecentAmount
  

  var drinkType: DrinkType {
    if _drinkType == nil {
      initDrinkType()
    }
    return _drinkType
  }

  fileprivate var _drinkType: DrinkType!

  var localizedName: String {
    return drinkType.localizedName
  }
  
  var mainColor: UIColor {
    return drinkType.mainColor
  }

  var darkColor: UIColor {
    return drinkType.darkColor
  }
  
  var drawDrinkFunction: StyleKit.DrawDrinkFunction {
    return drinkType.drawFunction
  }

  
  // MARK: Methods
  
  override func didChangeValue(forKey key: String) {
    super.didChangeValue(forKey: key)
    if key == "index" {
      _drinkType = nil
    }
  }

  fileprivate func initDrinkType() {
    if let drinkType = DrinkType(rawValue: index.intValue) {
      _drinkType = drinkType
    } else {
      _drinkType = .water // Just for exclude uncertainty
      Logger.logDrinkIsNotFound(drinkIndex: index.intValue)
    }
  }
  
  func drawDrink(frame: CGRect) {
    drawDrinkFunction(frame)
  }

  class func getDrinksCount() -> Int {
    return DrinkType.count
  }
  
  class func fetchDrinkByType(_ drinkType: DrinkType, managedObjectContext: NSManagedObjectContext) -> Drink? {
    return fetchDrinkByIndex(drinkType.rawValue, managedObjectContext: managedObjectContext)
  }
  
  class func fetchDrinkByIndex(_ index: Int, managedObjectContext: NSManagedObjectContext) -> Drink? {
    let predicate = NSPredicate(format: "%K = %@", argumentArray: ["index", index])
    return fetchManagedObject(managedObjectContext: managedObjectContext, predicate: predicate)
  }

  class func fetchAllDrinksIndexed(managedObjectContext: NSManagedObjectContext) -> [Int: Drink] {
    let drinks: [Drink] = fetchManagedObjects(managedObjectContext: managedObjectContext, predicate: nil, sortDescriptors: nil, fetchLimit: nil)
    
    var drinksMap = [Int: Drink]()
    for drink in drinks {
      drinksMap[drink.index.intValue] = drink
    }
    
    return drinksMap
  }

  class func fetchAllDrinksTyped(managedObjectContext: NSManagedObjectContext) -> [DrinkType: Drink] {
    let drinksIndexed = fetchAllDrinksIndexed(managedObjectContext: managedObjectContext)

    var drinksMap = [DrinkType: Drink]()

    for (index, drink) in drinksIndexed {
      if let drinkType = DrinkType(rawValue: index) {
        drinksMap[drinkType] = drink
      } else {
        assert(false, "Drink type with index (\(index)) is not found.")
      }
    }
    
    return drinksMap
  }
  
  class func addEntity(index: Int, name: String, hydrationFactor: Double, dehydrationFactor: Double, recentAmount amount: Double, managedObjectContext: NSManagedObjectContext, saveImmediately: Bool = true) -> Drink {
    let drink = Drink.insertNewObject(inManagedObjectContext: managedObjectContext)!
    drink.index = NSNumber(value: index)
    drink.name = name
    drink.hydrationFactor = hydrationFactor
    drink.dehydrationFactor = dehydrationFactor

    let recentAmount = RecentAmount.insertNewObject(inManagedObjectContext: managedObjectContext)!
    recentAmount.drink = drink
    recentAmount.amount = amount
    
    if saveImmediately {
      CoreDataStack.saveContext(managedObjectContext)
    }
    
    return drink
  }

}
