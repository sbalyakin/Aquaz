//
//  UnitItems.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 04.02.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation

enum UnitType: Int, CustomStringConvertible {
  case volume = 0
  case weight
  case length
  
  var description: String {
    switch self {
    case .volume: return "Volume"
    case .weight: return "Weight"
    case .length: return "Length"
    }
  }
}

protocol Unit {
  /// Unit type
  var type: UnitType { get }
  
  /// Number of the units in a curresponding base unit of metric system (e.g. number of pounds in kilograms)
  var factor: Double { get }
  
  /// Textual contraction of the unit
  var contraction: String { get }
}

class Quantity: CustomStringConvertible {
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
  
  /// Initializes quantity using conversion from another quantity
  init(ownUnit: Unit, fromQuantity: Quantity) {
    self.unit = ownUnit
    convertFrom(quantity: fromQuantity)
  }
  
  var description: String {
    return getDescription(fractionDigits: 0)
  }

  func getDescription(fractionDigits: Int, displayUnits: Bool = true) -> String {
    return getDescription(minimumFractionDigits: fractionDigits, maximumFractionDigits: fractionDigits, displayUnits: displayUnits)
  }

  func getDescription(minimumFractionDigits: Int, maximumFractionDigits: Int, displayUnits: Bool = true) -> String {
    struct Static {
      static let numberFormatter = NumberFormatter()
    }
    
    Static.numberFormatter.minimumFractionDigits = minimumFractionDigits
    Static.numberFormatter.maximumFractionDigits = maximumFractionDigits
    Static.numberFormatter.minimumIntegerDigits = 1
    Static.numberFormatter.numberStyle = .decimal
    
    var description = Static.numberFormatter.string(for: amount) ?? "0"
    
    if displayUnits {
      description += " \(unit.contraction)"
    }
    
    return description
  }
  
  static func convert(amount: Double, unitFrom: Unit, unitTo: Unit) -> Double {
    if unitFrom.type != unitTo.type {
      assert(false, "Incompatible unit is specified")
      return Double.nan
    }
    
    return amount * unitFrom.factor / unitTo.factor
  }
  
  func convertFrom(amount: Double, unit: Unit) {
    if unit.type != self.unit.type {
      assert(false, "Incompatible unit is specified")
      return
    }
    
    self.amount = Quantity.convert(amount: amount, unitFrom: unit, unitTo: self.unit)
  }
  
  func convertFrom(quantity: Quantity) {
    convertFrom(amount: quantity.amount, unit: quantity.unit)
  }
  
  let unit: Unit
  var amount: Double = 0.0
}

func +=(left: inout Quantity, right: Quantity) {
  let amount = left.amount
  left.convertFrom(quantity: right)
  left.amount += amount
}

func -=(left: inout Quantity, right: Quantity) {
  let amount = left.amount
  left.convertFrom(quantity: right)
  left.amount = amount - left.amount
}

private let milliliterUnitContraction = NSLocalizedString("U:mL",    value: "mL",    comment: "Units: contraction for milliliters")
private let fluidOunceUnitContraction = NSLocalizedString("U:fl oz", value: "fl oz", comment: "Units: contraction for fluid ounces")
private let kilogramUnitContraction   = NSLocalizedString("U:kg",    value: "kg",    comment: "Units: contraction for kilogrames")
private let poundUnitContraction      = NSLocalizedString("U:lb",    value: "lb",    comment: "Units: contraction for pounds")
private let centimiterUnitContraction = NSLocalizedString("U:cm",    value: "cm",    comment: "Units: contraction for centimeters")
private let footUnitContraction       = NSLocalizedString("U:ft",    value: "ft",    comment: "Units: contraction for feet")

class MilliliterUnit: Unit {
  init() {}
  let type: UnitType = .volume
  let factor: Double = 0.001
  let contraction: String = milliliterUnitContraction
}

class FluidOunceUnit: Unit {
  init() {}
  let type: UnitType = .volume
  let factor: Double = 0.0295735295625
  let contraction: String = fluidOunceUnitContraction
}

class KilogramUnit: Unit {
  init() {}
  let type: UnitType = .weight
  let factor: Double = 1
  let contraction: String = kilogramUnitContraction
}

class PoundUnit: Unit {
  init() {}
  let type: UnitType = .weight
  let factor: Double = 0.45359237
  let contraction: String = poundUnitContraction
}

class CentimeterUnit: Unit {
  init() {}
  let type: UnitType = .length
  let factor: Double = 0.01
  let contraction: String = centimiterUnitContraction
}

class FootUnit: Unit {
  init() {}
  let type: UnitType = .length
  let factor: Double = 0.3048
  let contraction: String = footUnitContraction
}
