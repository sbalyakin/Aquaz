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
  func adjustMetricAmountForStoring(#metricAmount: Double, unitType: UnitType, precision: Double = 1) -> Double {
    if precision == 0 {
      assert(false)
      return 0
    }

    let units = self.units[unitType.rawValue]
    let displayedQuantity = Quantity(ownUnit: units.displayedUnit, fromUnit: units.metricUnit, fromAmount: metricAmount)
    let displayedAmount = round(displayedQuantity.amount / precision) * precision
    let metricQuantity = Quantity(ownUnit: units.metricUnit, fromUnit: units.displayedUnit, fromAmount: displayedAmount)
    return metricQuantity.amount
  }
  
  func convertMetricAmountToDisplayed(#metricAmount: Double, unitType: UnitType, roundPrecision: Double = 1) -> Double {
    if roundPrecision == 0 {
      assert(false)
      return 0
    }
    
    let units = self.units[unitType.rawValue]
    var quantity = Quantity(ownUnit: units.displayedUnit, fromUnit: units.metricUnit, fromAmount: metricAmount)
    let displayedAmount = round(quantity.amount / roundPrecision) * roundPrecision
    return displayedAmount
  }
  
  /// Returns specified amount as formatted string taking into account current units settings.
  /// Amount should be specified in metric units.
  /// It's possible to specify final precision and numbers of decimals of formatted text.
  func formatMetricAmountToText(#metricAmount: Double, unitType: UnitType, roundPrecision: Double = 1, decimals: Int = 0, displayUnits: Bool = true) -> String {
    if roundPrecision == 0 {
      assert(false)
      return ""
    }
    
    let displayedAmount = convertMetricAmountToDisplayed(metricAmount: metricAmount, unitType: unitType, roundPrecision: roundPrecision)
    let units = self.units[unitType.rawValue]
    let quantity = Quantity(unit: units.displayedUnit, amount: displayedAmount)
    return quantity.getDescription(decimals, displayUnits: displayUnits)
  }
  
  private var units: [(metricUnit: Unit, displayedUnit: Unit)] = []

  private func onUpdateVolumeUnitsSettings(value: Units.Volume) {
    units[UnitType.Volume.rawValue] = (metricUnit: Volume.metric.unit, displayedUnit: value.unit)
  }
  
  private func onUpdateWeightUnitsSettings(value: Units.Weight) {
    units[UnitType.Weight.rawValue] = (metricUnit: Weight.metric.unit, displayedUnit: value.unit)
  }
  
  private func onUpdateHeightUnitsSettings(value: Units.Length) {
    units[UnitType.Length.rawValue] = (metricUnit: Length.metric.unit, displayedUnit: value.unit)
  }
  
  private init() {
    let displayedVolumeUnits = Settings.sharedInstance.generalVolumeUnits
    let displayedWeightUnits = Settings.sharedInstance.generalWeightUnits
    let displayedHeightUnits = Settings.sharedInstance.generalHeightUnits
    
    // Subscribe for changes of the settings
    displayedVolumeUnits.addObserver(onUpdateVolumeUnitsSettings)
    displayedWeightUnits.addObserver(onUpdateWeightUnitsSettings)
    displayedHeightUnits.addObserver(onUpdateHeightUnitsSettings)
    
    // Items order should correspond to UnitType elements order
    units = [(metricUnit: Volume.metric.unit, displayedUnit: displayedVolumeUnits.value.unit), // volume
             (metricUnit: Weight.metric.unit, displayedUnit: displayedWeightUnits.value.unit), // weight
             (metricUnit: Length.metric.unit, displayedUnit: displayedHeightUnits.value.unit)] // height
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

  func getDescription(decimals: Int, displayUnits: Bool = true) -> String {
    struct Static {
      static let numberFormatter = NSNumberFormatter()
    }

    Static.numberFormatter.minimumFractionDigits = decimals
    Static.numberFormatter.maximumFractionDigits = decimals
    Static.numberFormatter.minimumIntegerDigits = 1
    Static.numberFormatter.numberStyle = .DecimalStyle

    var description = "\(Static.numberFormatter.stringFromNumber(amount)!)"
    if displayUnits {
      description += " \(unit.contraction)"
    }
    
    return description
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
  let type: UnitType = .Volume
  let factor: Double = 0.001
  let contraction: String = "ml"
}

class FluidOunceUnit: Unit {
  let type: UnitType = .Volume
  let factor: Double = 0.0295735295625
  let contraction: String = "fl oz"
}

class KilogramUnit: Unit {
  let type: UnitType = .Weight
  let factor: Double = 1
  let contraction: String = "kg"
}

class PoundUnit: Unit {
  let type: UnitType = .Weight
  let factor: Double = 0.45359237
  let contraction: String = "lbs"
}

class CentimeterUnit: Unit {
  let type: UnitType = .Length
  let factor: Double = 0.01
  let contraction: String = "cm"
}

class FootUnit: Unit {
  let type: UnitType = .Length
  let factor: Double = 0.3048
  let contraction: String = "ft"
}


