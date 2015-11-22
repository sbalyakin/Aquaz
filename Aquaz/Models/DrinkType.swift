//
//  DrinkType.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 20.10.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

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
  
  var drawFunction: StyleKit.DrawDrinkFunction {
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
  
  var hydrationFactor: Double {
    switch self {
    case Water:      return 1.00
    case Coffee:     return 0.98
    case Tea:        return 0.99
    case Soda:       return 0.89
    case Juice:      return 0.85
    case Milk:       return 0.87
    case Sport:      return 0.95
    case Energy:     return 0.90
    case Beer:       return 0.95
    case Wine:       return 0.85
    case HardLiquor: return 0.60
    }
  }

  var dehydrationFactor: Double {
    switch self {
    case Water:      return 0
    case Coffee:     return 0
    case Tea:        return 0
    case Soda:       return 0
    case Juice:      return 0
    case Milk:       return 0
    case Sport:      return 0
    case Energy:     return 0
    case Beer:       return 0.5
    case Wine:       return 1.5
    case HardLiquor: return 4
    }
  }
  
}
