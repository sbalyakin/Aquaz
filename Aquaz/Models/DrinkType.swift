//
//  DrinkType.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 20.10.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

enum DrinkType: Int {
  case water = 0
  case coffee
  case tea
  case soda
  case juice
  case milk
  case sport
  case energy
  case beer
  case wine
  case hardLiquor
  
  fileprivate struct LocalizedStrings {
    static let waterTitle      = NSLocalizedString("D:Water",    value: "Water",    comment: "Drink: Title for water")
    static let coffeeTitle     = NSLocalizedString("D:Coffee",   value: "Coffee",   comment: "Drink: Title for coffee")
    static let teaTitle        = NSLocalizedString("D:Tea",      value: "Tea",      comment: "Drink: Title for tea")
    static let sodaTitle       = NSLocalizedString("D:Soda",     value: "Soda",     comment: "Drink: Title for soda")
    static let juiceTitle      = NSLocalizedString("D:Juice",    value: "Juice",    comment: "Drink: Title for juice")
    static let milkTitle       = NSLocalizedString("D:Milk",     value: "Milk",     comment: "Drink: Title for milk")
    static let sportTitle      = NSLocalizedString("D:Sport",    value: "Sport",    comment: "Drink: Title for sport drink")
    static let energyTitle     = NSLocalizedString("D:Energy",   value: "Energy",   comment: "Drink: Title for energetic drink")
    static let beerTitle       = NSLocalizedString("D:Beer",     value: "Beer",     comment: "Drink: Title for beer")
    static let wineTitle       = NSLocalizedString("D:Wine",     value: "Wine",     comment: "Drink: Title for wine")
    static let hardLiquorTitle = NSLocalizedString("D:Alc. 40°", value: "Alc. 40°", comment: "Drink: Title for hard liquor")
  }

  // Must be updated if new drink is added
  static var count: Int {
    return hardLiquor.rawValue + 1
  }
  
  var localizedName: String {
    switch self {
    case .water:      return LocalizedStrings.waterTitle
    case .coffee:     return LocalizedStrings.coffeeTitle
    case .tea:        return LocalizedStrings.teaTitle
    case .soda:       return LocalizedStrings.sodaTitle
    case .juice:      return LocalizedStrings.juiceTitle
    case .milk:       return LocalizedStrings.milkTitle
    case .sport:      return LocalizedStrings.sportTitle
    case .energy:     return LocalizedStrings.energyTitle
    case .beer:       return LocalizedStrings.beerTitle
    case .wine:       return LocalizedStrings.wineTitle
    case .hardLiquor: return LocalizedStrings.hardLiquorTitle
    }
  }
  
  var mainColor: UIColor {
    switch self {
    case .water:      return StyleKit.waterColor
    case .coffee:     return StyleKit.coffeeColor
    case .tea:        return StyleKit.teaColor
    case .soda:       return StyleKit.sodaColor
    case .juice:      return StyleKit.juiceColor
    case .milk:       return StyleKit.milkColor
    case .sport:      return StyleKit.sportColor
    case .energy:     return StyleKit.energyColor
    case .beer:       return StyleKit.beerColor
    case .wine:       return StyleKit.wineColor
    case .hardLiquor: return StyleKit.hardLiquorColor
    }
  }
  
  var darkColor: UIColor {
    return StyleKit.getDarkDrinkColor(fromMainColor: mainColor)
  }
  
  var drawFunction: StyleKit.DrawDrinkFunction {
    switch self {
    case .water:      return StyleKit.drawWaterDrink
    case .coffee:     return StyleKit.drawCoffeeDrink
    case .tea:        return StyleKit.drawTeaDrink
    case .soda:       return StyleKit.drawSodaDrink
    case .juice:      return StyleKit.drawJuiceDrink
    case .milk:       return StyleKit.drawMilkDrink
    case .sport:      return StyleKit.drawSportDrink
    case .energy:     return StyleKit.drawEnergyDrink
    case .beer:       return StyleKit.drawBeerDrink
    case .wine:       return StyleKit.drawWineDrink
    case .hardLiquor: return StyleKit.drawHardLiquorDrink
    }
  }
  
  var hydrationFactor: Double {
    switch self {
    case .water:      return 1.00
    case .coffee:     return 0.98
    case .tea:        return 0.99
    case .soda:       return 0.89
    case .juice:      return 0.85
    case .milk:       return 0.87
    case .sport:      return 0.95
    case .energy:     return 0.90
    case .beer:       return 0.95
    case .wine:       return 0.85
    case .hardLiquor: return 0.60
    }
  }

  var dehydrationFactor: Double {
    switch self {
    case .water:      return 0
    case .coffee:     return 0
    case .tea:        return 0
    case .soda:       return 0
    case .juice:      return 0
    case .milk:       return 0
    case .sport:      return 0
    case .energy:     return 0
    case .beer:       return 0.5
    case .wine:       return 1.5
    case .hardLiquor: return 4
    }
  }
  
  var caffeineGramPerLiter: Double {
    switch self {
    case .water:      return 0
    case .coffee:     return 0.632
    case .tea:        return 0.177
    case .soda:       return 0
    case .juice:      return 0
    case .milk:       return 0
    case .sport:      return 0
    case .energy:     return 0
    case .beer:       return 0
    case .wine:       return 0
    case .hardLiquor: return 0
    }
  }
  
}
