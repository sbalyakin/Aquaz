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
    case millilitres = 0
    case fluidOunces = 1
    
    static let metric = millilitres
    
    var unit: Unit {
      switch self {
      case millilitres: return MilliliterUnit()
      case fluidOunces: return FluidOunceUnit()
      }
    }
  }
  
  enum Weight: Int {
    case kilograms = 0
    case pounds = 1

    static let metric = kilograms

    var unit: Unit {
      switch self {
      case kilograms: return KilogramUnit()
      case pounds: return PoundUnit()
      }
    }
  }
  
  enum Length: Int {
    case centimeters = 0
    case feet = 1
    
    static let metric = centimeters
    
    var unit: Unit {
      switch self {
      case centimeters: return CentimeterUnit()
      case feet: return FootUnit()
      }
    }
  }
  
  class var sharedInstance: Units {
    struct Instance {
      static let instance = Units()
    }
    return Instance.instance
  }
  
  /// Returns specified amount as formatted string taking into units settings.
  /// Amount should be specified in metric units.
  func formatAmountToText(#amount: Double, unitType: UnitType) -> String {
    let units = self.units[unitType.rawValue]
    let quantity = Quantity(ownUnit: units.settingsUnit, fromUnit: units.internalUnit, fromAmount: amount)
    return quantity.description
  }
  
  func updateCache() {
    // Items order should correspond to UnitType elements order
    units = [(internalUnit: Volume.metric.unit, settingsUnit: Settings.General.volumeUnits.unit), // volume
             (internalUnit: Weight.metric.unit, settingsUnit: Settings.General.weightUnits.unit), // weight
             (internalUnit: Length.metric.unit, settingsUnit: Settings.General.heightUnits.unit)] // height
  }
  
  private var units: [(internalUnit: Unit, settingsUnit: Unit)] = []

  private init() {
    updateCache()
  }
}

enum UnitType: Int {
  case volume = 0
  case weight
  case length
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

  func getDescription(precision: Int) -> String {
    return String(format: "%.\(precision)f %@", arguments: [ amount, unit.contraction ])
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
  var type: UnitType = .volume
  var factor: Double = 0.001
  var contraction: String = "ml"
}

class FluidOunceUnit: Unit {
  var type: UnitType = .volume
  var factor: Double = 0.0295735295625
  var contraction: String = "fl oz"
}

class KilogramUnit: Unit {
  var type: UnitType = .weight
  var factor: Double = 1
  var contraction: String = "kg"
}

class PoundUnit: Unit {
  var type: UnitType = .weight
  var factor: Double = 0.45359237
  var contraction: String = "lb"
}

class CentimeterUnit: Unit {
  var type: UnitType = .length
  var factor: Double = 0.01
  var contraction: String = "cm"
}

class FootUnit: Unit {
  var type: UnitType = .length
  var factor: Double = 0.3048
  var contraction: String = "ft"
}


