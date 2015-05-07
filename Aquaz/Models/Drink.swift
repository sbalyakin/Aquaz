//
//  Drink.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 07.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc(Drink)
public class Drink: CodingManagedObject, NamedEntity {

  public static var entityName = "Drink"

  @NSManaged public var index: NSNumber
  @NSManaged public var name: String
  @NSManaged public var hydrationFactor: Double
  @NSManaged public var dehydrationFactor: Double
  @NSManaged public var intakes: NSSet
  @NSManaged public var recentAmount: RecentAmount

  private struct Static {
    static let waterTitle        = NSLocalizedString("D:Water",         value: "Water",         comment: "Drink: Title for water")
    static let coffeeTitle       = NSLocalizedString("D:Coffee",        value: "Coffee",        comment: "Drink: Title for coffee")
    static let teaTitle          = NSLocalizedString("D:Tea",           value: "Tea",           comment: "Drink: Title for tea")
    static let sodaTitle         = NSLocalizedString("D:Soda",          value: "Soda",          comment: "Drink: Title for soda")
    static let juiceTitle        = NSLocalizedString("D:Juice",         value: "Juice",         comment: "Drink: Title for juice")
    static let milkTitle         = NSLocalizedString("D:Milk",          value: "Milk",          comment: "Drink: Title for milk")
    static let sportTitle        = NSLocalizedString("D:Sport",         value: "Sport",         comment: "Drink: Title for sport drink")
    static let energyTitle       = NSLocalizedString("D:Energy",        value: "Energy",        comment: "Drink: Title for energetic drink")
    static let beerTitle         = NSLocalizedString("D:Beer",          value: "Beer",          comment: "Drink: Title for beer")
    static let wineTitle         = NSLocalizedString("D:Wine",          value: "Wine",          comment: "Drink: Title for wine")
    static let hardLiquorTitle   = NSLocalizedString("D:Hard Liquor",   value: "Hard Liquor",   comment: "Drink: Title for hard liquor")
    static let darkColorShadowLevel: CGFloat = 0.2
    // Use the cache to store previously used drink objects
    static var cachedDrinks = [Int: [Int: Drink]]()
  }
  
  // Important! Order of this enum must NOT be changed in further versions. New drinks must be added to the end.
  public enum DrinkType: Int {
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
  }

  public var drinkType: DrinkType {
    if _drinkType == nil {
      initIndexRelatedProperties()
      assert(_drinkType != nil)
    }
    return _drinkType
  }

  public var localizedName: String {
    if _localizedName == nil {
      initIndexRelatedProperties()
      assert(_localizedName != nil)
    }
    return _localizedName
  }
  
  public var mainColor: UIColor {
    if _mainColor == nil {
      initIndexRelatedProperties()
      assert(_mainColor != nil)
    }
    return _mainColor
  }

  public var darkColor: UIColor {
    if _darkColor == nil {
      initIndexRelatedProperties()
      assert(_darkColor != nil)
    }
    return _darkColor
  }
  
  public var drawDrinkFunction: DrawDrinkFunction {
    if _drawDrinkFunction == nil {
      initIndexRelatedProperties()
      assert(_drawDrinkFunction != nil)
    }
    return _drawDrinkFunction
  }

  override public func didChangeValueForKey(key: String) {
    super.didChangeValueForKey(key)
    if key == "index" {
      clearCachedProperties()
    }
  }

  private func clearCachedProperties() {
    _drinkType = nil
    _drawDrinkFunction = nil
    _localizedName = nil
    _mainColor = nil
    _darkColor = nil
  }
  
  private func initIndexRelatedProperties() {
    if let drinkTypeRaw = DrinkType(rawValue: index.integerValue) {
      _drinkType = drinkTypeRaw
    } else {
      Logger.logDrinkIsNotFound(drinkIndex: index.integerValue)
    }
    
    switch drinkType {
    case .Water:
      _localizedName = Static.waterTitle
      _drawDrinkFunction = StyleKit.drawWaterDrink
      _mainColor = StyleKit.waterColor
      
    case .Coffee:
      _localizedName = Static.coffeeTitle
      _drawDrinkFunction = StyleKit.drawCoffeeDrink
      _mainColor = StyleKit.coffeeColor
      
    case .Tea:
      _localizedName = Static.teaTitle
      _drawDrinkFunction = StyleKit.drawTeaDrink
      _mainColor = StyleKit.teaColor
      
    case .Soda:
      _localizedName = Static.sodaTitle
      _drawDrinkFunction = StyleKit.drawSodaDrink
      _mainColor = StyleKit.sodaColor
      
    case .Juice:
      _localizedName = Static.juiceTitle
      _drawDrinkFunction = StyleKit.drawJuiceDrink
      _mainColor = StyleKit.juiceColor
      
    case .Milk:
      _localizedName = Static.milkTitle
      _drawDrinkFunction = StyleKit.drawMilkDrink
      _mainColor = StyleKit.milkColor
      
    case .Sport:
      _localizedName = Static.sportTitle
      _drawDrinkFunction = StyleKit.drawSportDrink
      _mainColor = StyleKit.sportColor
      
    case .Energy:
      _localizedName = Static.energyTitle
      _drawDrinkFunction = StyleKit.drawEnergyDrink
      _mainColor = StyleKit.energyColor

    case .Beer:
      _localizedName = Static.beerTitle
      _drawDrinkFunction = StyleKit.drawBeerDrink
      _mainColor = StyleKit.beerColor
      
    case .Wine:
      _localizedName = Static.wineTitle
      _drawDrinkFunction = StyleKit.drawWineDrink
      _mainColor = StyleKit.wineColor
      
    case .HardLiquor:
      _localizedName = Static.hardLiquorTitle
      _drawDrinkFunction = StyleKit.drawHardLiquorDrink
      _mainColor = StyleKit.hardLiquorColor
    }
    
    _darkColor = Drink.getDarkColorFromDrinkColor(_mainColor)
  }
  
  class func getDarkColorFromDrinkColor(color: UIColor) -> UIColor {
    return color.colorWithShadow(Static.darkColorShadowLevel)
  }
  
  public func drawDrink(#frame: CGRect) {
    drawDrinkFunction(frame: frame)
  }

  public class func cacheAllDrinks(managedObjectContext: NSManagedObjectContext) {
    if Static.cachedDrinks.indexForKey(managedObjectContext.hash) != nil {
      return
    }
    
    let sortDescriptor = NSSortDescriptor(key: "index", ascending: true)
    let drinks: [Drink] = CoreDataHelper.fetchManagedObjects(managedObjectContext: managedObjectContext, predicate: nil, sortDescriptors: [sortDescriptor], fetchLimit: nil)

    var cache = [Int: Drink]()
    for drink in drinks {
      cache[drink.index.integerValue] = drink
    }
    
    Static.cachedDrinks[managedObjectContext.hash] = cache
  }
  
  public class func getDrinksCount() -> Int {
    return DrinkType.count
  }
  
  public class func getDrinkByType(drinkType: Drink.DrinkType, managedObjectContext: NSManagedObjectContext) -> Drink? {
    return getDrinkByIndex(drinkType.rawValue, managedObjectContext: managedObjectContext)
  }
  
  public class func getDrinkByIndex(index: Int, managedObjectContext: NSManagedObjectContext) -> Drink? {
    if let cache = Static.cachedDrinks[managedObjectContext.hash] {
      // Get the drink from cache
      let drink = cache[index]
      if drink == nil {
        Logger.logDrinkIsNotFound(drinkIndex: index)
      }
      return drink
    } else {
      // Fetch the drink from Core Data
      let predicate = NSPredicate(format: "%K = %@", argumentArray: ["index", index])
      if let drink: Drink = CoreDataHelper.fetchManagedObject(managedObjectContext: managedObjectContext, predicate: predicate) {
        return drink
      } else {
        Logger.logDrinkIsNotFound(drinkIndex: index)
        return nil
      }
    }
  }
  
  class func addEntity(#index: Int, name: String, hydrationFactor: Double, dehydrationFactor: Double, recentAmount amount: Double, managedObjectContext: NSManagedObjectContext, saveImmediately: Bool = true) -> Drink {
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
  
  public typealias DrawDrinkFunction = (frame: CGRect) -> Void
  
  private var _drinkType: DrinkType!
  private var _drawDrinkFunction: DrawDrinkFunction!
  private var _localizedName: String!
  private var _mainColor: UIColor!
  private var _darkColor: UIColor!

}
