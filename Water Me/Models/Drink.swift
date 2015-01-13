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
  @NSManaged var localizedName: String

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
    static let lightColorShadowLevel: CGFloat = 0.2
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

  var drinkType: DrinkType = .Water

  var mainColor: UIColor = StyleKit.waterColor {
    didSet {
      lightColor = Drink.getLightColorFrom(mainColor)
    }
  }
  
  var lightColor: UIColor = Drink.getLightColorFrom(StyleKit.waterColor)

  override func didChangeValueForKey(key: String) {
    super.didChangeValueForKey(key)
    if key == "index" {
      initRelatedProperties()
    }
  }

  override func awakeFromFetch() {
    super.awakeFromFetch()
    initRelatedProperties()
  }
  
  private func initRelatedProperties() {
    if let drinkTypeRaw = DrinkType(rawValue: index.integerValue) {
      drinkType = drinkTypeRaw
    } else {
      assert(false)
    }
    
    switch drinkType {
    case .Water:
      localizedName = Static.waterTitle
      drawDrinkFunction = StyleKit.drawWaterDrink
      mainColor = StyleKit.waterColor
      
    case .Coffee:
      localizedName = Static.coffeeTitle
      drawDrinkFunction = StyleKit.drawCoffeeDrink
      mainColor = StyleKit.coffeeColor
      
    case .Tea:
      localizedName = Static.teaTitle
      drawDrinkFunction = StyleKit.drawTeaDrink
      mainColor = StyleKit.teaColor
      
    case .Soda:
      localizedName = Static.sodaTitle
      drawDrinkFunction = StyleKit.drawSodaDrink
      mainColor = StyleKit.sodaColor
      
    case .Juice:
      localizedName = Static.juiceTitle
      drawDrinkFunction = StyleKit.drawJuiceDrink
      mainColor = StyleKit.juiceColor
      
    case .Milk:
      localizedName = Static.milkTitle
      drawDrinkFunction = StyleKit.drawMilkDrink
      mainColor = StyleKit.milkColor
      
    case .Alcohol:
      localizedName = Static.alcoholTitle
      drawDrinkFunction = StyleKit.drawAlcoholDrink
      mainColor = StyleKit.alcoholColor
      
    case .Sport:
      localizedName = Static.sportTitle
      drawDrinkFunction = StyleKit.drawSportDrink
      mainColor = StyleKit.sportColor
      
    case .Energy:
      localizedName = Static.energyTitle
      drawDrinkFunction = StyleKit.drawEnergyDrink
      mainColor = StyleKit.energyColor
    }
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

  private class func getLightColorFrom(color: UIColor) -> UIColor {
    return color.colorWithShadow(Static.lightColorShadowLevel)
  }

  private typealias DrawDrinkFunction = (frame: CGRect) -> Void
  private var drawDrinkFunction: DrawDrinkFunction = StyleKit.drawWaterDrink

}
