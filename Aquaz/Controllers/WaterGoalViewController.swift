//
//  WaterGoalViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 08.12.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
//

import UIKit
import CoreData
import HealthKit

class WaterGoalViewController: OmegaSettingsViewController {

  private struct LocalizedStrings {

    lazy var informationSectionHeader: String = NSLocalizedString("WGVC:Information About You", value: "Information About You",
      comment: "WaterGoalViewController: Header for section with personal information about user")
    
    lazy var genderTitle: String = NSLocalizedString("WGVC:Gender", value: "Gender",
      comment: "WaterGoalViewController: Table cell title for [Gender] setting")
    
    lazy var heightTitle: String = NSLocalizedString("WGVC:Height", value: "Height",
      comment: "WaterGoalViewController: Table cell title for [Height] setting")
    
    lazy var weightTitle: String = NSLocalizedString("WGVC:Weight", value: "Weight",
      comment: "WaterGoalViewController: Table cell title for [Weight] setting")
    
    lazy var ageTitle: String = NSLocalizedString("WGVC:Age", value: "Age",
      comment: "WaterGoalViewController: Table cell title for [Age] setting")
    
    lazy var physicalActivityTitle: String = NSLocalizedString("WGVC:Physical Activity", value: "Physical Activity",
      comment: "WaterGoalViewController: Table cell title for [Physical Activity] setting")
    
    lazy var dailyWaterIntakeTitle: String = NSLocalizedString("WGVC:Daily Water Intake", value: "Daily Water Intake",
      comment: "WaterGoalViewController: Table cell title for [Daily Water Intake] setting")
    
    lazy var dailyWaterIntakeSectionHeader: String = NSLocalizedString("WGVC:Recommendations", value: "Recommendations",
      comment: "WaterGoalViewController: Header for section with daily water intake")
    
    lazy var dailyWaterIntakeSectionFooter: String = NSLocalizedString("The calculated daily water intake is only an estimate. Always take into account your body\'s needs. Please consult your health care provider for advice about a specific medical condition.",
      value: "The calculated daily water intake is only an estimate. Always take into account your body\'s needs. Please consult your health care provider for advice about a specific medical condition.",
      comment: "Footer for section with calculated daily water intake")
    
    @available(iOS 9.0, *)
    lazy var readFromHealthTitle: String = NSLocalizedString("WGVC:Read Data from Apple Health", value: "Read Data from Apple Health",
      comment: "WaterGoalViewController: Table cell title for [Read Data from Apple Health] cell")
    
  }
  
  private var privateManagedObjectContext: NSManagedObjectContext { return CoreDataStack.privateContext }
  
  private var genderCell: RightDetailTableCell<Settings.Gender>!
  private var heightCell: TableCellWithValue<Double>!
  private var weightCell: TableCellWithValue<Double>!
  private var ageCell: TableCellWithValue<Int>!
  private var physicalActivityCell: TableCellWithValue<Settings.PhysicalActivity>!
  private var dailyWaterIntakeCell: TableCellWithValue<Double>!
  
  private let minimumAge = 10
  private let maximumAge = 100
  
  private var originalTableViewContentInset: UIEdgeInsets = UIEdgeInsetsZero
  
  private var localizedStrings = LocalizedStrings()

  
  override func viewDidLoad() {
    super.viewDidLoad()

    UIHelper.applyStyleToViewController(self)
    rightDetailValueColor = StyleKit.settingsTablesValueColor
    rightDetailSelectedValueColor = StyleKit.settingsTablesSelectedValueColor
  }
  
  override func createTableCellsSections() -> [TableCellsSection] {
    // Settings should be saved to user defaults only if user taps Done button
    saveToSettingsOnValueUpdate = false

    // Information section

    // Gender cell
    genderCell = createEnumRightDetailTableCell(
      title: localizedStrings.genderTitle,
      settingsItem: Settings.sharedInstance.userGender,
      pickerTableCellHeight: .Small,
      stringFromValueFunction: WaterGoalViewController.stringFromGender)
    
    if let pickerTableCell = genderCell.supportingTableCell as? PickerTableCell<Settings.Gender, EnumCollection<Settings.Gender>> {
      pickerTableCell.font = UIFont.systemFontOfSize(18)
    }

    genderCell.valueChangedFunction = { [weak self] in self?.sourceCellValueChanged($0) }
    
    // Height cell
    let heightUnit = Settings.sharedInstance.generalHeightUnits.value
    let heightCollection = DoubleCollection(
      minimumValue: heightUnit.minimumValue,
      maximumValue: heightUnit.maximumValue,
      step: heightUnit.step)
    
    heightCell = createRangedRightDetailTableCell(
      title: localizedStrings.heightTitle,
      settingsItem: Settings.sharedInstance.userHeight,
      collection: heightCollection,
      pickerTableCellHeight: .Large,
      stringFromValueFunction: WaterGoalViewController.stringFromHeight)
    
    heightCell.valueChangedFunction = { [weak self] in self?.sourceCellValueChanged($0) }
    
    // Weight cell
    let weightUnit = Settings.sharedInstance.generalWeightUnits.value
    let weightCollection = DoubleCollection(
      minimumValue: weightUnit.minimumValue,
      maximumValue: weightUnit.maximumValue,
      step: weightUnit.step)
    
    weightCell = createRangedRightDetailTableCell(
      title: localizedStrings.weightTitle,
      settingsItem: Settings.sharedInstance.userWeight,
      collection: weightCollection,
      pickerTableCellHeight: .Large,
      stringFromValueFunction: WaterGoalViewController.stringFromWeight)
    
    weightCell.valueChangedFunction = { [weak self] in self?.sourceCellValueChanged($0) }
    
    // Age cell
    let ageCollection = IntCollection(
      minimumValue: minimumAge,
      maximumValue: maximumAge,
      step: 1)
    
    ageCell = createRangedRightDetailTableCell(
      title: localizedStrings.ageTitle,
      settingsItem: Settings.sharedInstance.userAge,
      collection: ageCollection,
      pickerTableCellHeight: .Large,
      stringFromValueFunction: WaterGoalViewController.stringFromAge)
    
    ageCell.valueChangedFunction = { [weak self] in self?.sourceCellValueChanged($0) }
    
    // Physical activity cell
    physicalActivityCell = createEnumRightDetailTableCell(
      title: localizedStrings.physicalActivityTitle,
      settingsItem: Settings.sharedInstance.userPhysicalActivity,
      pickerTableCellHeight: .Small,
      stringFromValueFunction: WaterGoalViewController.stringFromPhysicalActivity)
    
    physicalActivityCell.valueChangedFunction = { [weak self] in self?.sourceCellValueChanged($0) }
    
    let informationSection = TableCellsSection()
    informationSection.headerTitle = localizedStrings.informationSectionHeader
    informationSection.tableCells = [
      genderCell,
      heightCell,
      weightCell,
      ageCell,
      physicalActivityCell]

    
    // Daily water intake section
    
    let volumeUnit = Settings.sharedInstance.generalVolumeUnits.value.unit
    let dailyWaterIntakeTitleFinal = "\(localizedStrings.dailyWaterIntakeTitle) (\(volumeUnit.contraction))"
    
    dailyWaterIntakeCell = createTextFieldTableCell(
      title: dailyWaterIntakeTitleFinal,
      settingsItem: Settings.sharedInstance.userDailyWaterIntake,
      valueFromStringFunction: WaterGoalViewController.metricWaterGoalFromString,
      stringFromValueFunction: WaterGoalViewController.stringFromWaterGoal,
      keyboardType: .DecimalPad)
    
    let dailyWaterIntakeSection = TableCellsSection()
    dailyWaterIntakeSection.headerTitle = localizedStrings.dailyWaterIntakeSectionHeader
    dailyWaterIntakeSection.footerTitle = localizedStrings.dailyWaterIntakeSectionFooter
    dailyWaterIntakeSection.tableCells = [dailyWaterIntakeCell]
    
    let sections: [TableCellsSection]
    
    // Read From Health section
    if #available(iOS 9.0, *) {
      let readFromHealthCell = createBasicTableCell(
        title: localizedStrings.readFromHealthTitle,
        accessoryType: nil,
        activationChangedFunction: { [weak self] _, active in
          if active {
            self?.checkHealthAuthorizationAndRead()
          }
        })
      
      readFromHealthCell.textColor = StyleKit.controlTintColor
      
      let healthSection = TableCellsSection()
      healthSection.tableCells = [readFromHealthCell]
      
      sections = [informationSection, healthSection, dailyWaterIntakeSection]
    } else {
      sections = [informationSection, dailyWaterIntakeSection]
    }
    
    return sections
  }
  
  private class func stringFromHeight(value: Double) -> String {
    let unit = Settings.sharedInstance.generalHeightUnits.value
    return Units.sharedInstance.formatMetricAmountToText(metricAmount: value, unitType: unit.unit.type, roundPrecision: unit.precision, decimals: unit.decimals, displayUnits: true)
  }
  
  private class func stringFromWeight(value: Double) -> String {
    let unit = Settings.sharedInstance.generalWeightUnits.value
    return Units.sharedInstance.formatMetricAmountToText(metricAmount: value, unitType: unit.unit.type, roundPrecision: unit.precision, decimals: unit.decimals, displayUnits: true)
  }
  
  private class func stringFromAge(value: Int) -> String {
    let formatter = NSNumberFormatter()
    formatter.numberStyle = .DecimalStyle
    formatter.maximumFractionDigits = 0
    let title = formatter.stringFromNumber(value)!
    return title
  }
  
  private class func stringFromGender(gender: Settings.Gender) -> String {
    switch gender {
    case .Man:
      return NSLocalizedString("WGVC:Man", value: "Man",
        comment: "WaterGoalViewController: [Man] option for gender")
      
    case .Woman:
      return NSLocalizedString("WGVC:Woman", value: "Woman",
        comment: "WaterGoalViewController: [Woman] option for gender")
      
    case .PregnantFemale:
      return NSLocalizedString("WGVC:Woman: pregnant", value: "Woman: pregnant",
        comment: "WaterGoalViewController: [Woman: pregnant] option for gender")
      
    case .BreastfeedingFemale:
      return NSLocalizedString("WGVC:Woman: breastfeeding", value: "Woman: breastfeeding",
        comment: "WaterGoalViewController: [Woman: breastfeeding] option for gender")
    }
  }

  private class func stringFromPhysicalActivity(physicalActivity: Settings.PhysicalActivity) -> String {
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
  
  private class func stringFromWaterGoal(value: Double) -> String {
    let unit = Settings.sharedInstance.generalVolumeUnits.value
    let displayedAmount = Units.sharedInstance.convertMetricAmountToDisplayed(metricAmount: value, unitType: unit.unit.type, roundPrecision: unit.precision)
    let formatter = NSNumberFormatter()
    formatter.minimumFractionDigits = unit.decimals
    formatter.maximumFractionDigits = unit.decimals
    formatter.minimumIntegerDigits = 1
    formatter.numberStyle = .NoStyle
    let title = formatter.stringFromNumber(displayedAmount) ?? "0"
    return title
  }
  
  private class func metricWaterGoalFromString(value: String) -> Double? {
    if let displayedValue = NSNumberFormatter().numberFromString(value)?.doubleValue {
      if displayedValue <= 0 {
        return nil
      }
      
      let displayedUnit = Settings.sharedInstance.generalVolumeUnits.value
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
    privateManagedObjectContext.performBlock {
      WaterGoal.addEntity(
        date: NSDate(),
        baseAmount: self.dailyWaterIntakeCell.value,
        isHotDay: false,
        isHighActivity: false,
        managedObjectContext: self.privateManagedObjectContext)
    }
  }

  private func sourceCellValueChanged(tableCell: TableCell) {
    // Just for sure that cell are still alive
    if let physicalActivityCell = physicalActivityCell,
       let genderCell = genderCell,
       let ageCell = ageCell,
       let heightCell = heightCell,
       let weightCell = weightCell,
       let dailyWaterIntakeCell = dailyWaterIntakeCell
    {
      let data = WaterGoalCalculator.Data(
        physicalActivity: physicalActivityCell.value,
        gender:           genderCell.value,
        age:              ageCell.value,
        height:           heightCell.value,
        weight:           weightCell.value,
        country:          .Average)
      
      let waterGoalAmount = WaterGoalCalculator.calcDailyWaterIntake(data: data)

      dailyWaterIntakeCell.value = waterGoalAmount
    }
  }
  
  // MARK: HealthKit
  @available(iOS 9.0, *)
  private func checkHealthAuthorizationAndRead() {
    HealthKitProvider.sharedInstance.authorizeHealthKit { authorized, _ in
      if authorized {
        self.readFromHealthKit()
      }
    }
  }
  
  @available(iOS 9.0, *)
  private func readFromHealthKit() {
    HealthKitProvider.sharedInstance.readUserProfile { age, biologicalSex, bodyMass, height in
      dispatch_async(dispatch_get_main_queue()) {
        if let age = age {
          Settings.sharedInstance.userAge.value = age
        }
        
        if let biologicalSex = biologicalSex {
          Settings.sharedInstance.userGender.value.applyBiologicalSex(biologicalSex)
        }
        
        if let bodyMass = bodyMass {
          let bodyMassInKilograms = bodyMass.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix(.Kilo))
          Settings.sharedInstance.userWeight.value = bodyMassInKilograms
        }
        
        if let height = height {
          let heightInCentimeter = height.quantity.doubleValueForUnit(HKUnit.meterUnitWithMetricPrefix(.Centi))
          Settings.sharedInstance.userHeight.value = heightInCentimeter
        }
        
        self.recreateTableCellsSections()
      }
    }
  }

}

private extension Units.Weight {
  var minimumValue: Double {
    switch self {
    case Kilograms: return 30
    case Pounds:    return 29.93709642
    }
  }
  
  var maximumValue: Double {
    switch self {
    case Kilograms: return 300
    case Pounds:    return 299.3709642
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

@available(iOS 9.0, *)
private extension Settings.Gender {
  mutating func applyBiologicalSex(biologicalSex: HKBiologicalSex) {
    switch biologicalSex {
    case .Male:   self = .Man
    case .Female: self = .Woman
    case .NotSet: return
    case .Other:  return
    }
  }
}
