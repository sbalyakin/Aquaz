//
//  Units.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 27.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation

class Units {
  
  enum Volume: Int, Printable {
    case Millilitres = 0
    case FluidOunces
    
    static let metric = Millilitres
    
    var unit: Unit {
      switch self {
      case Millilitres: return MilliliterUnit()
      case FluidOunces: return FluidOunceUnit()
      }
    }
    
    var description: String {
      return unit.contraction
    }
  }
  
  enum Weight: Int, Printable {
    case Kilograms = 0
    case Pounds

    static let metric = Kilograms

    var unit: Unit {
      switch self {
      case Kilograms: return KilogramUnit()
      case Pounds: return PoundUnit()
      }
    }
    
    var description: String {
      return unit.contraction
    }
  }
  
  enum Length: Int, Printable {
    case Centimeters = 0
    case Feet
    
    static let metric = Centimeters
    
    var unit: Unit {
      switch self {
      case Centimeters: return CentimeterUnit()
      case Feet: return FootUnit()
      }
    }
    
    var description: String {
      return unit.contraction
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
  func adjustMetricAmountForStoring(#metricAmount: Double, unitType: UnitType, roundPrecision: Double = 1) -> Double {
    if roundPrecision <= 0 {
      assert(false, "Round precision should be positive number")
      return 0
    }

    let units = self.units[unitType.rawValue]
    let displayedQuantity = Quantity(ownUnit: units.displayedUnit, fromUnit: units.metricUnit, fromAmount: metricAmount)
    let displayedAmount = round(displayedQuantity.amount / roundPrecision) * roundPrecision
    let metricQuantity = Quantity(ownUnit: units.metricUnit, fromUnit: units.displayedUnit, fromAmount: displayedAmount)
    return metricQuantity.amount
  }
  
  func convertMetricAmountToDisplayed(#metricAmount: Double, unitType: UnitType, roundPrecision: Double = 1) -> Double {
    if roundPrecision <= 0 {
      assert(false, "Round precision should be positive number")
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
    if roundPrecision <= 0 {
      assert(false, "Round precision should be positive number")
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

