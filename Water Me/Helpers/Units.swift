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
  }
  
  enum Weight: Int {
    case kilograms = 0
    case pounds = 1
  }
  
  enum Length: Int {
    case centimeters = 0
    case feet = 1
  }
  
}

enum UnitType {
  case volume
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
  init(unit: Unit, amount: Double = 0.0) {
    self.unit = unit
    self.amount = amount
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


