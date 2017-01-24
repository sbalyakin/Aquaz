//
//  Units.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 27.10.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
//

import Foundation

class Units {
  
  enum Volume: Int, CustomStringConvertible {
    case millilitres = 0
    case fluidOunces
    
    static let metric = millilitres
    
    var unit: Unit {
      switch self {
      case .millilitres: return MilliliterUnit()
      case .fluidOunces: return FluidOunceUnit()
      }
    }
    
    var description: String {
      return unit.contraction
    }
  }
  
  enum Weight: Int, CustomStringConvertible {
    case kilograms = 0
    case pounds

    static let metric = kilograms

    var unit: Unit {
      switch self {
      case .kilograms: return KilogramUnit()
      case .pounds: return PoundUnit()
      }
    }
    
    var description: String {
      return unit.contraction
    }
  }
  
  enum Length: Int, CustomStringConvertible {
    case centimeters = 0
    case feet
    
    static let metric = centimeters
    
    var unit: Unit {
      switch self {
      case .centimeters: return CentimeterUnit()
      case .feet: return FootUnit()
      }
    }
    
    var description: String {
      return unit.contraction
    }
  }
  
  static let sharedInstance = Units()
  
  /// Prepares specified amount for storing into Core Data. It converts metric units of amount to current units from settings.
  /// Then it rounds converted amount and makes reverse conversion to metric units.
  /// This methods allows getting amount equals to formatted amount (formatAmountToText) but represented in metric units.
  func adjustMetricAmountForStoring(metricAmount: Double, unitType: UnitType, roundPrecision: Double = 1) -> Double {
    if roundPrecision <= 0 {
      assert(false, "Round precision should be positive number")
      return 0
    }

    let units = getUnits(unitType)
    let displayedQuantity = Quantity(ownUnit: units.displayedUnit, fromUnit: units.metricUnit, fromAmount: metricAmount)
    let displayedAmount = round(displayedQuantity.amount / roundPrecision) * roundPrecision
    let metricQuantity = Quantity(ownUnit: units.metricUnit, fromUnit: units.displayedUnit, fromAmount: displayedAmount)
    return metricQuantity.amount
  }
  
  func convertMetricAmountToDisplayed(metricAmount: Double, unitType: UnitType, roundPrecision: Double = 1) -> Double {
    if roundPrecision <= 0 {
      assert(false, "Round precision should be positive number")
      return 0
    }
    
    let units = getUnits(unitType)
    let quantity = Quantity(ownUnit: units.displayedUnit, fromUnit: units.metricUnit, fromAmount: metricAmount)
    let displayedAmount = round(quantity.amount / roundPrecision) * roundPrecision
    return displayedAmount
  }
  
  /// Returns specified amount as formatted string taking into account current units settings.
  /// Amount should be specified in metric units.
  /// It's possible to specify final precision and numbers of decimals of formatted text.
  func formatMetricAmountToText(metricAmount: Double, unitType: UnitType, roundPrecision: Double, fractionDigits: Int, displayUnits: Bool) -> String {
    return formatMetricAmountToText(metricAmount: metricAmount, unitType: unitType, roundPrecision: roundPrecision, minimumFractionDigits: fractionDigits, maximumFractionDigits: fractionDigits, displayUnits: displayUnits)
  }

  func formatMetricAmountToText(metricAmount: Double, unitType: UnitType, roundPrecision: Double, minimumFractionDigits: Int, maximumFractionDigits: Int, displayUnits: Bool) -> String {
    if roundPrecision <= 0 {
      assert(false, "Round precision should be positive number")
      return ""
    }
    
    let displayedAmount = convertMetricAmountToDisplayed(metricAmount: metricAmount, unitType: unitType, roundPrecision: roundPrecision)
    let units = getUnits(unitType)
    let quantity = Quantity(unit: units.displayedUnit, amount: displayedAmount)
    return quantity.getDescription(minimumFractionDigits: minimumFractionDigits, maximumFractionDigits: maximumFractionDigits, displayUnits: displayUnits)
  }
  
  fileprivate func getUnits(_ unitType: UnitType) -> (metricUnit: Unit, displayedUnit: Unit) {
    switch unitType {
    case .length:
      return (metricUnit: Length.metric.unit, displayedUnit: Length.settings.unit)
      
    case .volume:
      return (metricUnit: Volume.metric.unit, displayedUnit: Volume.settings.unit)
      
    case .weight:
      return (metricUnit: Weight.metric.unit, displayedUnit: Weight.settings.unit)
    }
  }
}

