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

  // MARK: Types
  
  private struct LocalizedStrings {
    static let waterTitle      = NSLocalizedString("D:Water",       value: "Water",       comment: "Drink: Title for water")
    static let coffeeTitle     = NSLocalizedString("D:Coffee",      value: "Coffee",      comment: "Drink: Title for coffee")
    static let teaTitle        = NSLocalizedString("D:Tea",         value: "Tea",         comment: "Drink: Title for tea")
    static let sodaTitle       = NSLocalizedString("D:Soda",        value: "Soda",        comment: "Drink: Title for soda")
    static let juiceTitle      = NSLocalizedString("D:Juice",       value: "Juice",       comment: "Drink: Title for juice")
    static let milkTitle       = NSLocalizedString("D:Milk",        value: "Milk",        comment: "Drink: Title for milk")
    static let sportTitle      = NSLocalizedString("D:Sport",       value: "Sport",       comment: "Drink: Title for sport drink")
    static let energyTitle     = NSLocalizedString("D:Energy",      value: "Energy",      comment: "Drink: Title for energetic drink")
    static let beerTitle       = NSLocalizedString("D:Beer",        value: "Beer",        comment: "Drink: Title for beer")
    static let wineTitle       = NSLocalizedString("D:Wine",        value: "Wine",        comment: "Drink: Title for wine")
    static let hardLiquorTitle = NSLocalizedString("D:Hard Liquor", value: "Hard Liquor", comment: "Drink: Title for hard liquor")
  }
  
  // Important! Order of this enum must NOT be changed in further versions. New drinks must be added to the end.
  enum DrinkType: Int {
    case Water = 0
    case Coffee
    case Tea
    case Soda
    case Juice
    case Milk
    case Sport
    case Energy
    case Beer
    case Wine
    case HardLiquor

    // Must be updated if new drink is added
    static var count: Int {
      return HardLiquor.rawValue + 1
    }
    
    var localizedName: String {
      switch self {
      case Water:      return LocalizedStrings.waterTitle
      case Coffee:     return LocalizedStrings.coffeeTitle
      case Tea:        return LocalizedStrings.teaTitle
      case Soda:       return LocalizedStrings.sodaTitle
      case Juice:      return LocalizedStrings.juiceTitle
      case Milk:       return LocalizedStrings.milkTitle
      case Sport:      return LocalizedStrings.sportTitle
      case Energy:     return LocalizedStrings.energyTitle
      case Beer:       return LocalizedStrings.beerTitle
      case Wine:       return LocalizedStrings.wineTitle
      case HardLiquor: return LocalizedStrings.hardLiquorTitle
      }
    }
    
    var mainColor: UIColor {
      switch self {
      case Water:      return StyleKit.waterColor
      case Coffee:     return StyleKit.coffeeColor
      case Tea:        return StyleKit.teaColor
      case Soda:       return StyleKit.sodaColor
      case Juice:      return StyleKit.juiceColor
      case Milk:       return StyleKit.milkColor
      case Sport:      return StyleKit.sportColor
      case Energy:     return StyleKit.energyColor
      case Beer:       return StyleKit.beerColor
      case Wine:       return StyleKit.wineColor
      case HardLiquor: return StyleKit.hardLiquorColor
      }
    }
    
    var darkColor: UIColor {
      return StyleKit.getDarkDrinkColor(fromMainColor: mainColor)
    }
    
    var drawFunction: DrawDrinkFunction {
      switch self {
      case Water:      return StyleKit.drawWaterDrink
      case Coffee:     return StyleKit.drawCoffeeDrink
      case Tea:        return StyleKit.drawTeaDrink
      case Soda:       return StyleKit.drawSodaDrink
      case Juice:      return StyleKit.drawJuiceDrink
      case Milk:       return StyleKit.drawMilkDrink
      case Sport:      return StyleKit.drawSportDrink
      case Energy:     return StyleKit.drawEnergyDrink
      case Beer:       return StyleKit.drawBeerDrink
      case Wine:       return StyleKit.drawWineDrink
      case HardLiquor: return StyleKit.drawHardLiquorDrink
      }
    }
  }

  typealias DrawDrinkFunction = (frame: CGRect) -> Void
  
  
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
  
  var drawDrinkFunction: DrawDrinkFunction {
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
  
  class func fetchDrinkByType(drinkType: Drink.DrinkType, managedObjectContext: NSManagedObjectContext) -> Drink? {
    return fetchDrinkByIndex(drinkType.rawValue, managedObjectContext: managedObjectContext)
  }
  
  class func fetchDrinkByIndex(index: Int, managedObjectContext: NSManagedObjectContext) -> Drink? {
    let predicate = NSPredicate(format: "%K = %@", argumentArray: ["index", index])
    if let drink: Drink = CoreDataHelper.fetchManagedObject(managedObjectContext: managedObjectContext, predicate: predicate) {
      return drink
    } else {
      Logger.logDrinkIsNotFound(drinkIndex: index)
      return nil
    }
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
