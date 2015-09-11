//
//  UnitItems.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 04.02.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import Foundation

public enum UnitType: Int, CustomStringConvertible {
  case Volume = 0
  case Weight
  case Length
  
  public var description: String {
    switch self {
    case Volume: return "Volume"
    case Weight: return "Weight"
    case Length: return "Length"
    }
  }
}

public protocol Unit {
  /// Unit type
  var type: UnitType { get }
  
  /// Number of the units in a curresponding base unit of metric system (e.g. number of pounds in kilograms)
  var factor: Double { get }
  
  /// Textual contraction of the unit
  var contraction: String { get }
}

public class Quantity: CustomStringConvertible {
  /// Initalizes quantity with specified unit and amount
  public init(unit: Unit, amount: Double = 0.0) {
    self.unit = unit
    self.amount = amount
  }
  
  /// Initializes quantity using conversion from another amount of units
  public init(ownUnit: Unit, fromUnit: Unit, fromAmount: Double) {
    self.unit = ownUnit
    convertFrom(amount: fromAmount, unit: fromUnit)
  }
  
  /// Initializes quantity using conversion from another quantity
  public init(ownUnit: Unit, fromQuantity: Quantity) {
    self.unit = ownUnit
    convertFrom(quantity: fromQuantity)
  }
  
  public var description: String {
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
    
    var description = Static.numberFormatter.stringFromNumber(amount) ?? "0"
    if displayUnits {
      description += " \(unit.contraction)"
    }
    
    return description
  }
  
  public func convertFrom(amount amount: Double, unit: Unit) {
    if unit.type != self.unit.type {
      assert(false, "Incompatible unit is specified")
      return
    }
    self.amount = amount * unit.factor / self.unit.factor
  }
  
  public func convertFrom(quantity quantity: Quantity) {
    convertFrom(amount: quantity.amount, unit: quantity.unit)
  }
  
  public let unit: Unit
  public var amount: Double = 0.0
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

private let milliliterUnitContraction = NSLocalizedString("U:mL",    value: "mL",    comment: "Units: contraction for milliliters")
private let fluidOunceUnitContraction = NSLocalizedString("U:fl oz", value: "fl oz", comment: "Units: contraction for fluid ounces")
private let kilogramUnitContraction   = NSLocalizedString("U:kg",    value: "kg",    comment: "Units: contraction for kilogrames")
private let poundUnitContraction      = NSLocalizedString("U:lb",    value: "lb",    comment: "Units: contraction for pounds")
private let centimiterUnitContraction = NSLocalizedString("U:cm",    value: "cm",    comment: "Units: contraction for centimeters")
private let footUnitContraction       = NSLocalizedString("U:ft",    value: "ft",    comment: "Units: contraction for feet")

public class MilliliterUnit: Unit {
  public init() {}
  public let type: UnitType = .Volume
  public let factor: Double = 0.001
  public let contraction: String = milliliterUnitContraction
}

public class FluidOunceUnit: Unit {
  public init() {}
  public let type: UnitType = .Volume
  public let factor: Double = 0.0295735295625
  public let contraction: String = fluidOunceUnitContraction
}

public class KilogramUnit: Unit {
  public init() {}
  public let type: UnitType = .Weight
  public let factor: Double = 1
  public let contraction: String = kilogramUnitContraction
}

public class PoundUnit: Unit {
  public init() {}
  public let type: UnitType = .Weight
  public let factor: Double = 0.45359237
  public let contraction: String = poundUnitContraction
}

public class CentimeterUnit: Unit {
  public init() {}
  public let type: UnitType = .Length
  public let factor: Double = 0.01
  public let contraction: String = centimiterUnitContraction
}

public class FootUnit: Unit {
  public init() {}
  public let type: UnitType = .Length
  public let factor: Double = 0.3048
  public let contraction: String = footUnitContraction
}