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

  private var _drinkType: DrinkType!

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
  
  override func didChangeValueForKey(key: String) {
    super.didChangeValueForKey(key)
    if key == "index" {
      _drinkType = nil
    }
  }

  private func initDrinkType() {
    if let drinkType = DrinkType(rawValue: index.integerValue) {
      _drinkType = drinkType
    } else {
      _drinkType = .Water // Just for exclude uncertainty
      Logger.logDrinkIsNotFound(drinkIndex: index.integerValue)
    }
  }
  
  func drawDrink(frame frame: CGRect) {
    drawDrinkFunction(frame: frame)
  }

  class func getDrinksCount() -> Int {
    return DrinkType.count
  }
  
  class func fetchDrinkByType(drinkType: DrinkType, managedObjectContext: NSManagedObjectContext) -> Drink? {
    return fetchDrinkByIndex(drinkType.rawValue, managedObjectContext: managedObjectContext)
  }
  
  class func fetchDrinkByIndex(index: Int, managedObjectContext: NSManagedObjectContext) -> Drink? {
    let predicate = NSPredicate(format: "%K = %@", argumentArray: ["index", index])
    return CoreDataHelper.fetchManagedObject(managedObjectContext: managedObjectContext, predicate: predicate)
  }

  class func fetchAllDrinksIndexed(managedObjectContext managedObjectContext: NSManagedObjectContext) -> [Int: Drink] {
    let drinks: [Drink] = CoreDataHelper.fetchManagedObjects(managedObjectContext: managedObjectContext, predicate: nil, sortDescriptors: nil, fetchLimit: nil)
    
    var drinksMap = [Int: Drink]()
    for drink in drinks {
      drinksMap[drink.index.integerValue] = drink
    }
    
    return drinksMap
  }

  class func fetchAllDrinksTyped(managedObjectContext managedObjectContext: NSManagedObjectContext) -> [DrinkType: Drink] {
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
  
  class func addEntity(index index: Int, name: String, hydrationFactor: Double, dehydrationFactor: Double, recentAmount amount: Double, managedObjectContext: NSManagedObjectContext, saveImmediately: Bool = true) -> Drink {
    let drink = LoggedActions.insertNewObjectForEntity(Drink.self, inManagedObjectContext: managedObjectContext)!
    drink.index = index
    drink.name = name
    drink.hydrationFactor = hydrationFactor
    drink.dehydrationFactor = dehydrationFactor

    let recentAmount = LoggedActions.insertNewObjectForEntity(RecentAmount.self, inManagedObjectContext: managedObjectContext)!
    recentAmount.drink = drink
    recentAmount.amount = amount
    
    if saveImmediately {
      CoreDataStack.saveContext(managedObjectContext)
    }
    
    return drink
  }

}
