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
  @NSManaged var name: String
  @NSManaged var waterPercent: NSNumber
  @NSManaged var consumptions: NSSet
  @NSManaged var recentAmount: RecentAmount

  private struct Static {
    static let waterTitle   = NSLocalizedString("D:Water",   value: "Water",   comment: "Drink: Title for water")
    static let coffeeTitle  = NSLocalizedString("D:Coffee",  value: "Coffee",  comment: "Drink: Title for coffee")
    static let teaTitle     = NSLocalizedString("D:Tea",     value: "Tea",     comment: "Drink: Title for tea")
    static let sodaTitle    = NSLocalizedString("D:Soda",    value: "Soda",    comment: "Drink: Title for soda")
    static let juiceTitle   = NSLocalizedString("D:Juice",   value: "Juice",   comment: "Drink: Title for juice")
    static let milkTitle    = NSLocalizedString("D:Milk",    value: "Milk",    comment: "Drink: Title for milk")
    static let alcoholTitle = NSLocalizedString("D:Alcohol", value: "Alcohol", comment: "Drink: Title for alcohol")
    static let sportTitle   = NSLocalizedString("D:Sport",   value: "Sport",   comment: "Drink: Title for sport drink")
    static let energyTitle  = NSLocalizedString("D:Energy",  value: "Energy",  comment: "Drink: Title for energetic drink")
    static let darkColorShadowLevel: CGFloat = 0.2
    // Use the cache to store previously used drink objects
    static var cachedDrinks: [Int: Drink] = [:]
  }
  
  enum DrinkType: Int {
    case Water = 0
    case Coffee
    case Tea
    case Soda
    case Juice
    case Milk
    case Alcohol
    case Sport
    case Energy

    static var count: Int {
      return Energy.rawValue + 1
    }
  }

  var drinkType: DrinkType {
    if _drinkType == nil {
      initIndexRelatedProperties()
      assert(_drinkType != nil)
    }
    return _drinkType
  }

  var localizedName: String {
    if _localizedName == nil {
      initIndexRelatedProperties()
      assert(_localizedName != nil)
    }
    return _localizedName
  }
  
  var mainColor: UIColor {
    if _mainColor == nil {
      initIndexRelatedProperties()
      assert(_mainColor != nil)
    }
    return _mainColor
  }

  var darkColor: UIColor {
    if _darkColor == nil {
      initIndexRelatedProperties()
      assert(_darkColor != nil)
    }
    return _darkColor
  }
  
  private var drawDrinkFunction: DrawDrinkFunction {
    if _drawDrinkFunction == nil {
      initIndexRelatedProperties()
      assert(_drawDrinkFunction != nil)
    }
    return _drawDrinkFunction
  }
  

  override func didChangeValueForKey(key: String) {
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
      assert(false)
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
      
    case .Alcohol:
      _localizedName = Static.alcoholTitle
      _drawDrinkFunction = StyleKit.drawAlcoholDrink
      _mainColor = StyleKit.alcoholColor
      
    case .Sport:
      _localizedName = Static.sportTitle
      _drawDrinkFunction = StyleKit.drawSportDrink
      _mainColor = StyleKit.sportColor
      
    case .Energy:
      _localizedName = Static.energyTitle
      _drawDrinkFunction = StyleKit.drawEnergyDrink
      _mainColor = StyleKit.energyColor
    }
    
    _darkColor = _mainColor.colorWithShadow(Static.darkColorShadowLevel)
  }
  
  func drawDrink(#frame: CGRect) {
    drawDrinkFunction(frame: frame)
  }

  class func getEntityName() -> String {
    return "Drink"
  }
  
  class func getDrinksCount() -> Int {
    return DrinkType.count
  }
  
  class func getDrinkByIndex(index: Int) -> Drink? {
    // Try to search for the drink in the cache
    if let drink = Static.cachedDrinks[index] {
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
      Static.cachedDrinks[index] = drink
    }
    
    return drink
  }
  
  class func addEntity(#index: Int, name: String, waterPercent: NSNumber, recentAmount amount: NSNumber, managedObjectContext: NSManagedObjectContext) -> Drink {
    let drink = NSEntityDescription.insertNewObjectForEntityForName(Drink.getEntityName(), inManagedObjectContext: managedObjectContext) as Drink
    drink.index = index
    drink.name = name
    drink.waterPercent = waterPercent

    let recentAmount = NSEntityDescription.insertNewObjectForEntityForName(RecentAmount.getEntityName(), inManagedObjectContext: managedObjectContext) as RecentAmount
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

  private typealias DrawDrinkFunction = (frame: CGRect) -> Void
  
  private var _drinkType: DrinkType!
  private var _drawDrinkFunction: DrawDrinkFunction!
  private var _localizedName: String!
  private var _mainColor: UIColor!
  private var _darkColor: UIColor!

}
