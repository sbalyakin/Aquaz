//
//  UnitsHelper.swift
//  Water Me
//
//  Created by Sergey Balyakin on 27.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation

class Units {
  
  enum Volume: Int {
    case Millilitres = 0
    case FluidOunces
    
    static let metric = Millilitres
    
    var unit: Unit {
      switch self {
      case Millilitres: return MilliliterUnit()
      case FluidOunces: return FluidOunceUnit()
      }
    }
  }
  
  enum Weight: Int {
    case Kilograms = 0
    case Pounds

    static let metric = Kilograms

    var unit: Unit {
      switch self {
      case Kilograms: return KilogramUnit()
      case Pounds: return PoundUnit()
      }
    }
  }
  
  enum Length: Int {
    case Centimeters = 0
    case Feet
    
    static let metric = Centimeters
    
    var unit: Unit {
      switch self {
      case Centimeters: return CentimeterUnit()
      case Feet: return FootUnit()
      }
    }
  }
  
  class var sharedInstance: Units {
    struct Instance {
      static let instance = Units()
    }
    return Instance.instance
  }
  
  /// Prepares specified amount for storing into Core Data. It converts metric units of amount to current units from settings.
  /// Then it rounds converted amount and makes reverse conversion to metric units.
  /// This methods allows getting amount equals to formatted amount (formatAmountToText) but represented in metric units.
  func prepareAmountForStoring(#amount: Double, unitType: UnitType, precision: Double = 1) -> Double {
    let units = self.units[unitType.rawValue]
    let currentQuantity = Quantity(ownUnit: units.settingsUnit, fromUnit: units.internalUnit, fromAmount: amount)
    let currentAmount = round(currentQuantity.amount / precision) * precision
    let metricQuantity = Quantity(ownUnit: units.internalUnit, fromUnit: units.settingsUnit, fromAmount: currentAmount)
    return metricQuantity.amount
  }
  
  /// Returns specified amount as formatted string taking into account current units settings.
  /// Amount should be specified in metric units.
  // It's possible to specify final precision and numbers of decimals of formatted text.
  func formatAmountToText(#amount: Double, unitType: UnitType, precision: Double = 1, decimals: Int = 0) -> String {
    let units = self.units[unitType.rawValue]
    var quantity = Quantity(ownUnit: units.settingsUnit, fromUnit: units.internalUnit, fromAmount: amount)
    quantity.amount = round(quantity.amount / precision) * precision
    return quantity.getDescription(decimals)
  }
  
  private var units: [(internalUnit: Unit, settingsUnit: Unit)] = []

  private func onUpdateVolumeUnitsSettings(value: Units.Volume) {
    units[UnitType.Volume.rawValue] = (internalUnit: Volume.metric.unit, settingsUnit: value.unit)
  }
  
  private func onUpdateWeightUnitsSettings(value: Units.Weight) {
    units[UnitType.Weight.rawValue] = (internalUnit: Weight.metric.unit, settingsUnit: value.unit)
  }
  
  private func onUpdateHeightUnitsSettings(value: Units.Length) {
    units[UnitType.Length.rawValue] = (internalUnit: Length.metric.unit, settingsUnit: value.unit)
  }
  
  private init() {
    let settingsVolumeUnits = Settings.sharedInstance.generalVolumeUnits
    let settingsWeightUnits = Settings.sharedInstance.generalWeightUnits
    let settingsHeightUnits = Settings.sharedInstance.generalHeightUnits
    
    // Subscribe for changes of the settings
    settingsVolumeUnits.addObserver(onUpdateVolumeUnitsSettings)
    settingsWeightUnits.addObserver(onUpdateWeightUnitsSettings)
    settingsHeightUnits.addObserver(onUpdateHeightUnitsSettings)
    
    // Items order should correspond to UnitType elements order
    units = [(internalUnit: Volume.metric.unit, settingsUnit: settingsVolumeUnits.value.unit), // volume
             (internalUnit: Weight.metric.unit, settingsUnit: settingsWeightUnits.value.unit), // weight
             (internalUnit: Length.metric.unit, settingsUnit: settingsHeightUnits.value.unit)] // height
  }
}

enum UnitType: Int {
  case Volume = 0
  case Weight
  case Length
}

protocol Unit {
  /// Unit type
  var type: UnitType { get }
  
  /// Number of the units in a curresponding base unit of metric system (e.g. number of pounds in kilograms)
  var factor: Double { get }
  
  /// Textual contraction of the unit
  var contraction: String { get }
}

class Quantity {
  /// Initalizes quantity with specified unit and amount
  init(unit: Unit, amount: Double = 0.0) {
    self.unit = unit
    self.amount = amount
  }

  /// Initializes quantity using conversion from another amount of units
  init(ownUnit: Unit, fromUnit: Unit, fromAmount: Double) {
    self.unit = ownUnit
    convertFrom(amount: fromAmount, unit: fromUnit)
  }
  
  var description: String {
    return getDescription(0)
  }

  func getDescription(decimals: Int) -> String {
    struct Static {
      static let numberFormatter = NSNumberFormatter()
    }

    Static.numberFormatter.minimumFractionDigits = decimals
    Static.numberFormatter.maximumFractionDigits = decimals
    // TODO: Test locale
    Static.numberFormatter.locale = NSLocale.currentLocale()

    return "\(Static.numberFormatter.stringFromNumber(amount)!) \(unit.contraction)"
  }
  
  func convertFrom(#amount:Double, unit: Unit) {
    if unit.type != self.unit.type {
      assert(false, "Incompatible unit is specified")
      return
    }
    self.amount = amount * unit.factor / self.unit.factor
  }
  
  func convertFrom(#quantity: Quantity) {
    convertFrom(amount: quantity.amount, unit: quantity.unit)
  }
  
  let unit: Unit
  var amount: Double = 0.0
}

func +=(inout left: Quantity, right: Quantity) {
  let amount = left.amount
  left.convertFrom(quantity: right)
  left.amount += amount
}

func -=(inout left: Quantity, right: Quantity) {
  let amount = left.amount
  left.convertFrom(quantity: right)
  left.amount = amount - left.amount
}

class MilliliterUnit: Unit {
  var type: UnitType = .Volume
  var factor: Double = 0.001
  var contraction: String = "ml"
}

class FluidOunceUnit: Unit {
  var type: UnitType = .Volume
  var factor: Double = 0.0295735295625
  var contraction: String = "fl oz"
}

class KilogramUnit: Unit {
  var type: UnitType = .Weight
  var factor: Double = 1
  var contraction: String = "kg"
}

class PoundUnit: Unit {
  var type: UnitType = .Weight
  var factor: Double = 0.45359237
  var contraction: String = "lb"
}

class CentimeterUnit: Unit {
  var type: UnitType = .Length
  var factor: Double = 0.01
  var contraction: String = "cm"
}

class FootUnit: Unit {
  var type: UnitType = .Length
  var factor: Double = 0.3048
  var contraction: String = "ft"
}


