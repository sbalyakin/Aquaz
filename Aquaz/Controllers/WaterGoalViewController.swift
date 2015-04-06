//
//  WaterGoalViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 08.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit
import CoreData

class WaterGoalViewController: OmegaSettingsViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()

    UIHelper.applyStyle(self)
    rightDetailValueColor = StyleKit.settingsTablesValueColor
    rightDetailSelectedValueColor = StyleKit.settingsTablesSelectedValueColor
  }
  
  override func createTableCellsSections() -> [TableCellsSection] {
    // Settings should be saved to user defaults only if user taps Done button
    saveToSettingsOnValueUpdate = false
    
    let genderTitle = NSLocalizedString("WGVC:Gender", value: "Gender",
      comment: "WaterGoalViewController: Table cell title for [Gender] setting")
    
    let heightTitle = NSLocalizedString("WGVC:Height", value: "Height",
      comment: "WaterGoalViewController: Table cell title for [Height] setting")
    
    let weightTitle = NSLocalizedString("WGVC:Weight", value: "Weight",
      comment: "WaterGoalViewController: Table cell title for [Weight] setting")
    
    let ageTitle = NSLocalizedString("WGVC:Age", value: "Age",
      comment: "WaterGoalViewController: Table cell title for [Age] setting")
    
    let physicalActivityTitle = NSLocalizedString("WGVC:Physical Activity", value: "Physical Activity",
      comment: "WaterGoalViewController: Table cell title for [Physical Activity] setting")
    
    let waterGoalTitle = NSLocalizedString("WGVC:Water Intake", value: "Water Intake",
      comment: "WaterGoalViewController: Table cell title for [Water Intake] setting")
    
    // Gender cell
    genderCell = createEnumRightDetailTableCell(
      title: genderTitle,
      settingsItem: Settings.userGender,
      pickerTableCellHeight: .Small,
      stringFromValueFunction: stringFromGender)
    
    genderCell.valueChangedFunction = sourceCellValueChanged
    
    // Height cell
    let heightUnit = Settings.generalHeightUnits.value
    let heightCollection = DoubleCollection(
      minimumValue: heightUnit.minimumValue,
      maximumValue: heightUnit.maximumValue,
      step: heightUnit.step)
    
    heightCell = createRangedRightDetailTableCell(
      title: heightTitle,
      settingsItem: Settings.userHeight,
      collection: heightCollection,
      pickerTableCellHeight: .Large,
      stringFromValueFunction: stringFromHeight)
    
    heightCell.valueChangedFunction = sourceCellValueChanged
    
    // Weight cell
    let weightUnit = Settings.generalWeightUnits.value
    let weightCollection = DoubleCollection(
      minimumValue: weightUnit.minimumValue,
      maximumValue: weightUnit.maximumValue,
      step: weightUnit.step)
    
    weightCell = createRangedRightDetailTableCell(
      title: weightTitle,
      settingsItem: Settings.userWeight,
      collection: weightCollection,
      pickerTableCellHeight: .Large,
      stringFromValueFunction: stringFromWeight)
    
    weightCell.valueChangedFunction = sourceCellValueChanged
    
    // Age cell
    let ageCollection = IntCollection(
      minimumValue: minimumAge,
      maximumValue: maximumAge,
      step: 1)
    
    ageCell = createRangedRightDetailTableCell(
      title: ageTitle,
      settingsItem: Settings.userAge,
      collection: ageCollection,
      pickerTableCellHeight: .Large,
      stringFromValueFunction: stringFromAge)
    
    ageCell.valueChangedFunction = sourceCellValueChanged
    
    // Physical activity cell
    physicalActivityCell = createEnumRightDetailTableCell(
      title: physicalActivityTitle,
      settingsItem: Settings.userPhysicalActivity,
      pickerTableCellHeight: .Small,
      stringFromValueFunction: stringFromPhysicalActivity)
    
    physicalActivityCell.valueChangedFunction = sourceCellValueChanged
    
    let volumeUnit = Settings.generalVolumeUnits.value.unit
    let waterGoalTitleFinal = waterGoalTitle +  " (\(volumeUnit.contraction))"
    
    waterGoalCell = createTextFieldTableCell(
      title: waterGoalTitleFinal, settingsItem:
      Settings.userWaterGoal,
      valueFromStringFunction: metricWaterGoalFromString,
      stringFromValueFunction: stringFromWaterGoal,
      keyboardType: .DecimalPad)
    
    // Table sections
    let section1 = TableCellsSection()
    section1.tableCells = [
      genderCell,
      heightCell,
      weightCell,
      ageCell,
      physicalActivityCell]
    
    let section2 = TableCellsSection()
    section2.tableCells = [waterGoalCell]
    
    return [section1, section2]
  }
  
  private func stringFromHeight(value: Double) -> String {
    let unit = Settings.generalHeightUnits.value
    return Units.sharedInstance.formatMetricAmountToText(metricAmount: value, unitType: unit.unit.type, roundPrecision: unit.precision, decimals: unit.decimals, displayUnits: true)
  }
  
  private func stringFromWeight(value: Double) -> String {
    let unit = Settings.generalWeightUnits.value
    return Units.sharedInstance.formatMetricAmountToText(metricAmount: value, unitType: unit.unit.type, roundPrecision: unit.precision, decimals: unit.decimals, displayUnits: true)
  }
  
  private func stringFromAge(value: Int) -> String {
    let formatter = NSNumberFormatter()
    formatter.numberStyle = .DecimalStyle
    formatter.maximumFractionDigits = 0
    let title = formatter.stringFromNumber(value)!
    return title
  }
  
  private func stringFromGender(gender: Settings.Gender) -> String {
    switch gender {
    case .Man:
      return NSLocalizedString("WGVC:Man", value: "Man",
        comment: "WaterGoalViewController: [Man] option for gender")
      
    case .Woman:
      return NSLocalizedString("WGVC:Woman", value: "Woman",
        comment: "WaterGoalViewController: [Woman] option for gender")
      
    case .PregnantFemale:
      return NSLocalizedString("WGVC:Pregnant female", value: "Pregnant female",
        comment: "WaterGoalViewController: [Pregnant female] option for gender")
      
    case .BreastfeedingFemale:
      return NSLocalizedString("WGVC:Breastfeeding female", value: "Breastfeeding female",
        comment: "WaterGoalViewController: [Breastfeeding female] option for gender")
    }
  }
  
  private func stringFromPhysicalActivity(physicalActivity: Settings.PhysicalActivity) -> String {
    switch physicalActivity {
    case .Rare:
      return NSLocalizedString("WGVC:Rare", value: "Rare",
        comment: "WaterGoalViewController: [Rare] option for physical activity")
      
    case .Occasional:
      return NSLocalizedString("WGVC:Occasional", value: "Occasional",
        comment: "WaterGoalViewController: [Occasional] option for physical activity")
      
    case .Weekly:
      return NSLocalizedString("WGVC:Weekly", value: "Weekly",
        comment: "WaterGoalViewController: [Weekly] option for physical activity")
      
    case .Daily:
      return NSLocalizedString("WGVC:Daily", value: "Daily",
        comment: "WaterGoalViewController: [Daily] option for physical activity")
    }
  }
  
  private func stringFromWaterGoal(value: Double) -> String {
    let unit = Settings.generalVolumeUnits.value
    let displayedAmount = Units.sharedInstance.convertMetricAmountToDisplayed(metricAmount: value, unitType: unit.unit.type, roundPrecision: unit.precision)
    let formatter = NSNumberFormatter()
    formatter.minimumFractionDigits = unit.decimals
    formatter.maximumFractionDigits = unit.decimals
    formatter.minimumIntegerDigits = 1
    formatter.numberStyle = .NoStyle
    let title = formatter.stringFromNumber(displayedAmount) ?? "0"
    return title
  }
  
  private func metricWaterGoalFromString(value: String) -> Double? {
    if let displayedValue = NSNumberFormatter().numberFromString(value)?.doubleValue {
      if displayedValue <= 0 {
        return nil
      }
      
      let displayedUnit = Settings.generalVolumeUnits.value
      let quantity = Quantity(ownUnit: Units.Volume.metric.unit, fromUnit: displayedUnit.unit, fromAmount: displayedValue)
      let metricValue = quantity.amount
      let adjustedMetricValue = Units.sharedInstance.adjustMetricAmountForStoring(metricAmount: metricValue, unitType: .Volume, roundPrecision: displayedUnit.precision)
      return adjustedMetricValue
    } else {
      return nil
    }
  }
  
  @IBAction func cancelButtonWasTapped(sender: AnyObject) {
    activateTableCell(nil)
    navigationController?.popViewControllerAnimated(true)
  }
  
  @IBAction func doneButtonWasTapped(sender: AnyObject) {
    activateTableCell(nil)
    saveToSettings()
    navigationController?.popViewControllerAnimated(true)
  }
  
  private func saveToSettings() {
    writeTableCellValuesToExternalStorage()
    saveWaterGoalToCoreData()
  }

  private func saveWaterGoalToCoreData() {
    let date = NSDate()
    if let waterGoal = WaterGoal.fetchWaterGoalStrictlyForDate(date, managedObjectContext: CoreDataProvider.sharedInstance.managedObjectContext) {
      waterGoal.baseAmount = waterGoalCell.value
      CoreDataProvider.sharedInstance.saveContext()
    } else {
      WaterGoal.addEntity(
        date: date,
        baseAmount: waterGoalCell.value,
        isHotDay: false,
        isHighActivity: false,
        managedObjectContext: CoreDataProvider.sharedInstance.managedObjectContext)
    }
  }

  private func sourceCellValueChanged(tableCell: TableCell) {
    let data = WaterGoalCalculator.Data(physicalActivity: physicalActivityCell.value, gender: genderCell.value, age: ageCell.value, height: heightCell.value, weight: weightCell.value, country: .Average)
    
    let waterGoalAmount = WaterGoalCalculator.calcDailyWaterIntake(data: data)

    waterGoalCell.value = waterGoalAmount
  }
  
  private var genderCell: TableCellWithValue<Settings.Gender>!
  private var heightCell: TableCellWithValue<Double>!
  private var weightCell: TableCellWithValue<Double>!
  private var ageCell: TableCellWithValue<Int>!
  private var physicalActivityCell: TableCellWithValue<Settings.PhysicalActivity>!
  private var waterGoalCell: TableCellWithValue<Double>!
  
  private let minimumAge = 10
  private let maximumAge = 100
  
  private var originalTableViewContentInset: UIEdgeInsets = UIEdgeInsetsZero
  
}

private extension Units.Weight {
  var minimumValue: Double {
    switch self {
    case Kilograms: return 1
    case Pounds:    return 1
    }
  }
  
  var maximumValue: Double {
    switch self {
    case Kilograms: return 300
    case Pounds:    return 660
    }
  }
  
  var step: Double {
    switch self {
    case Kilograms: return 1
    case Pounds:    return 1
    }
  }
  
  var precision: Double {
    switch self {
    case Kilograms: return 1
    case Pounds:    return 1
    }
  }
  
  var decimals: Int {
    switch self {
    case Kilograms: return 0
    case Pounds:    return 0
    }
  }
}

private extension Units.Length {
  var minimumValue: Double {
    switch self {
    case Centimeters: return 30
    case Feet:        return 30.48 // 1 foot
    }
  }
  
  var maximumValue: Double {
    switch self {
    case Centimeters: return 300
    case Feet:        return 304.8 // 10 feet
    }
  }
  
  var step: Double {
    switch self {
    case Centimeters: return 1
    case Feet:        return 3.048 // 0.1 feet
    }
  }
  
  var precision: Double {
    switch self {
    case Centimeters: return 1
    case Feet:        return 0.1
    }
  }
  
  var decimals: Int {
    switch self {
    case Centimeters: return 0
    case Feet:        return 1
    }
  }
}

private extension Units.Volume {
  var precision: Double {
    switch self {
    case Millilitres: return 1
    case FluidOunces: return 0.1
    }
  }
  
  var decimals: Int {
    switch self {
    case Millilitres: return 0
    case FluidOunces: return 1
    }
  }
}

