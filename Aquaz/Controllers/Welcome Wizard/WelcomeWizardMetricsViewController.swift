//
//  WelcomeWizardMetricsViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 04.04.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit
import CoreData
import HealthKit

final class WelcomeWizardMetricsViewController: OmegaSettingsViewController {

  fileprivate struct LocalizedStrings {
    
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
    
    lazy var dailyWaterIntakeSectionFooter: String = NSLocalizedString("The calculated daily water intake is only an estimate. Always take into account your body\'s needs. Please consult your health care provider for advice about a specific medical condition.",
      value: "The calculated daily water intake is only an estimate. Always take into account your body\'s needs. Please consult your health care provider for advice about a specific medical condition.",
      comment: "Footer for section with calculated daily water intake")
    
    @available(iOS 9.0, *)
    lazy var readFromHealthTitle: String = NSLocalizedString("WGVC:Read Data from Apple Health", value: "Read Data from Apple Health",
      comment: "WaterGoalViewController: Table cell title for [Read Data from Apple Health] cell")
  }
  
  @IBOutlet weak var descriptionLabel: UILabel!
  
  fileprivate var genderCell: RightDetailTableCell<Settings.Gender>!
  fileprivate var heightCell: TableCellWithValue<Double>!
  fileprivate var weightCell: TableCellWithValue<Double>!
  fileprivate var ageCell: TableCellWithValue<Int>!
  fileprivate var physicalActivityCell: TableCellWithValue<Settings.PhysicalActivity>!
  fileprivate var dailyWaterIntakeCell: TableCellWithValue<Double>!
  
  fileprivate let minimumAge = 10
  fileprivate let maximumAge = 100
  
  fileprivate var originalTableViewContentInset: UIEdgeInsets = UIEdgeInsets.zero
  
  fileprivate var heightObserver: SettingsObserver?
  fileprivate var weightObserver: SettingsObserver?
  fileprivate var volumeObserver: SettingsObserver?
  
  fileprivate var localizedStrings = LocalizedStrings()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    UIHelper.applyStyleToViewController(self)
    rightDetailValueColor = StyleKit.settingsTablesValueColor
    rightDetailSelectedValueColor = StyleKit.settingsTablesSelectedValueColor

    initObserving()
    
    if #available(iOS 9.0, *) {
      readFromHealthKit()
    }
  }

  fileprivate func initObserving() {
    heightObserver = Settings.sharedInstance.generalHeightUnits.addObserver { [weak self] _ in
      self?.recreateTableCellsSections()
    }
    
    weightObserver = Settings.sharedInstance.generalWeightUnits.addObserver { [weak self] _ in
      self?.recreateTableCellsSections()
    }
    
    volumeObserver = Settings.sharedInstance.generalVolumeUnits.addObserver { [weak self] _ in
      self?.recreateTableCellsSections()
    }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    if let headerView = tableView.tableHeaderView {
      headerView.setNeedsLayout()
      headerView.layoutIfNeeded()
      
      // It's ugly way to update header, but unfortunately I've not found any better way.
      let originalHeight = descriptionLabel.frame.height
      let newHeight = descriptionLabel.sizeThatFits(CGSize(width: descriptionLabel.frame.width, height: CGFloat.greatestFiniteMagnitude)).height
      descriptionLabel.frame.size.height = newHeight
      
      let deltaHeight = newHeight - originalHeight
      if deltaHeight != 0 {
        headerView.frame.size.height += deltaHeight
        tableView.tableHeaderView = headerView
        view.layoutIfNeeded()
      }
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    saveWaterGoalToCoreData()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    if tableView.contentSize.height > tableView.frame.size.height {
      let offset = CGPoint(x: 0, y: tableView.contentSize.height - tableView.frame.size.height)
      tableView.setContentOffset(offset, animated: true)
    }
  }
  
  override func createTableCellsSections() -> [TableCellsSection] {
    // Information section
    
    // Gender cell
    genderCell = createEnumRightDetailTableCell(
      title: localizedStrings.genderTitle,
      settingsItem: Settings.sharedInstance.userGender,
      stringFromValueFunction: WelcomeWizardMetricsViewController.stringFromGender,
      pickerTableCellHeight: .small)
    
    if let pickerTableCell = genderCell.supportingTableCell as? PickerTableCell<Settings.Gender, EnumCollection<Settings.Gender>> {
      pickerTableCell.font = UIFont.systemFont(ofSize: 18)
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
      stringFromValueFunction: WelcomeWizardMetricsViewController.stringFromHeight,
      pickerTableCellHeight: .large)
    
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
      stringFromValueFunction: WelcomeWizardMetricsViewController.stringFromWeight,
      pickerTableCellHeight: .large)
    
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
      stringFromValueFunction: WelcomeWizardMetricsViewController.stringFromAge,
      pickerTableCellHeight: .large)
    
    ageCell.valueChangedFunction = { [weak self] in self?.sourceCellValueChanged($0) }
    
    // Physical activity cell
    physicalActivityCell = createEnumRightDetailTableCell(
      title: localizedStrings.physicalActivityTitle,
      settingsItem: Settings.sharedInstance.userPhysicalActivity,
      stringFromValueFunction: WelcomeWizardMetricsViewController.stringFromPhysicalActivity,
      pickerTableCellHeight: .small)
    
    physicalActivityCell.valueChangedFunction = { [weak self] in self?.sourceCellValueChanged($0) }
    
    let volumeUnit = Settings.sharedInstance.generalVolumeUnits.value.unit
    let dailyWaterIntakeTitleFinal = "\(localizedStrings.dailyWaterIntakeTitle) (\(volumeUnit.contraction))"

    let informationSection = TableCellsSection()
    informationSection.tableCells = [
      genderCell,
      heightCell,
      weightCell,
      ageCell,
      physicalActivityCell]

    // Daily Water Intake section
    
    dailyWaterIntakeCell = createTextFieldTableCell(
      title: dailyWaterIntakeTitleFinal, settingsItem:
      Settings.sharedInstance.userDailyWaterIntake,
      valueFromStringFunction: WelcomeWizardMetricsViewController.metricWaterGoalFromString,
      stringFromValueFunction: WelcomeWizardMetricsViewController.stringFromWaterGoal,
      keyboardType: .decimalPad)
    
    let dailyWaterIntakeSection = TableCellsSection()
    dailyWaterIntakeSection.footerTitle = localizedStrings.dailyWaterIntakeSectionFooter
    dailyWaterIntakeSection.tableCells = [dailyWaterIntakeCell]

    let sections: [TableCellsSection]
    
    // Read From Health section
    if #available(iOS 9.0, *) {
      let readFromHealthCell = createBasicTableCell(
        title: localizedStrings.readFromHealthTitle,
        accessoryType: nil)
      
      readFromHealthCell.activationChangedFunction = { [weak self] _, active in
        if active {
          self?.readFromHealthKit()
        }
      }
      
      readFromHealthCell.textColor = StyleKit.controlTintColor
      
      let healthSection = TableCellsSection()
      healthSection.tableCells = [readFromHealthCell]
      
      sections = [informationSection, healthSection, dailyWaterIntakeSection]
    } else {
      sections = [informationSection, dailyWaterIntakeSection]
    }

    return sections
  }
  
  fileprivate class func stringFromHeight(_ value: Double) -> String {
    let unit = Settings.sharedInstance.generalHeightUnits.value
    return Units.sharedInstance.formatMetricAmountToText(metricAmount: value, unitType: unit.unit.type, roundPrecision: unit.precision, fractionDigits: unit.decimals, displayUnits: true)
  }
  
  fileprivate class func stringFromWeight(_ value: Double) -> String {
    let unit = Settings.sharedInstance.generalWeightUnits.value
    return Units.sharedInstance.formatMetricAmountToText(metricAmount: value, unitType: unit.unit.type, roundPrecision: unit.precision, fractionDigits: unit.decimals, displayUnits: true)
  }
  
  fileprivate class func stringFromAge(_ value: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 0
    let title = formatter.string(for: value)!
    return title
  }
  
  fileprivate class func stringFromGender(_ gender: Settings.Gender) -> String {
    switch gender {
    case .man:
      return NSLocalizedString("WGVC:Man", value: "Man",
        comment: "WaterGoalViewController: [Man] option for gender")
      
    case .woman:
      return NSLocalizedString("WGVC:Woman", value: "Woman",
        comment: "WaterGoalViewController: [Woman] option for gender")
      
    case .pregnantFemale:
      return NSLocalizedString("WGVC:Woman: pregnant", value: "Woman: pregnant",
        comment: "WaterGoalViewController: [Woman: pregnant] option for gender")
      
    case .breastfeedingFemale:
      return NSLocalizedString("WGVC:Woman: breastfeeding", value: "Woman: breastfeeding",
        comment: "WaterGoalViewController: [Woman: breastfeeding] option for gender")
    }
  }
  
  fileprivate class func stringFromPhysicalActivity(_ physicalActivity: Settings.PhysicalActivity) -> String {
    switch physicalActivity {
    case .rare:
      return NSLocalizedString("WGVC:Rare", value: "Rare",
        comment: "WaterGoalViewController: [Rare] option for physical activity")
      
    case .occasional:
      return NSLocalizedString("WGVC:Occasional", value: "Occasional",
        comment: "WaterGoalViewController: [Occasional] option for physical activity")
      
    case .weekly:
      return NSLocalizedString("WGVC:Weekly", value: "Weekly",
        comment: "WaterGoalViewController: [Weekly] option for physical activity")
      
    case .daily:
      return NSLocalizedString("WGVC:Daily", value: "Daily",
        comment: "WaterGoalViewController: [Daily] option for physical activity")
    }
  }
  
  fileprivate class func stringFromWaterGoal(_ value: Double) -> String {
    let unit = Settings.sharedInstance.generalVolumeUnits.value
    let displayedAmount = Units.sharedInstance.convertMetricAmountToDisplayed(metricAmount: value, unitType: unit.unit.type, roundPrecision: unit.precision)
    let formatter = NumberFormatter()
    formatter.minimumFractionDigits = unit.decimals
    formatter.maximumFractionDigits = unit.decimals
    formatter.minimumIntegerDigits = 1
    formatter.numberStyle = .none
    let title = formatter.string(for: displayedAmount) ?? "0"
    return title
  }
  
  fileprivate class func metricWaterGoalFromString(_ value: String) -> Double? {
    if let displayedValue = NumberFormatter().number(from: value)?.doubleValue {
      if displayedValue <= 0 {
        return nil
      }
      
      let displayedUnit = Settings.sharedInstance.generalVolumeUnits.value
      let quantity = Quantity(ownUnit: Units.Volume.metric.unit, fromUnit: displayedUnit.unit, fromAmount: displayedValue)
      let metricValue = quantity.amount
      let adjustedMetricValue = Units.sharedInstance.adjustMetricAmountForStoring(metricAmount: metricValue, unitType: .volume, roundPrecision: displayedUnit.precision)
      return adjustedMetricValue
    } else {
      return nil
    }
  }
  
  fileprivate func saveWaterGoalToCoreData() {
    CoreDataStack.performOnPrivateContext { privateContext in
      _ = WaterGoal.addEntity(
        date: Date(),
        baseAmount: self.dailyWaterIntakeCell.value,
        isHotDay: false,
        isHighActivity: false,
        managedObjectContext: privateContext)
    }
  }
  
  fileprivate func sourceCellValueChanged(_ tableCell: TableCell) {
    let data = WaterGoalCalculator.Data(physicalActivity: physicalActivityCell.value, gender: genderCell.value, age: ageCell.value, height: heightCell.value, weight: weightCell.value, country: .Average)
    
    let waterGoalAmount = WaterGoalCalculator.calcDailyWaterIntake(data: data)
    
    dailyWaterIntakeCell.value = waterGoalAmount
  }

  // MARK: HealthKit
  @available(iOS 9.0, *)
  fileprivate func readFromHealthKit() {
    HealthKitProvider.sharedInstance.readUserProfile { age, biologicalSex, bodyMass, height in
      DispatchQueue.main.async {
        if let age = age {
          Settings.sharedInstance.userAge.value = age
        }
        
        if let biologicalSex = biologicalSex {
          Settings.sharedInstance.userGender.value.applyBiologicalSex(biologicalSex)
        }
        
        if let bodyMass = bodyMass {
          let bodyMassInKilograms = bodyMass.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
          Settings.sharedInstance.userWeight.value = bodyMassInKilograms
        }
        
        if let height = height {
          let heightInCentimeter = height.quantity.doubleValue(for: HKUnit.meterUnit(with: .centi))
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
    case .kilograms: return 30
    case .pounds:    return 29.93709642
    }
  }
  
  var maximumValue: Double {
    switch self {
    case .kilograms: return 300
    case .pounds:    return 299.3709642
    }
  }
  
  var step: Double {
    switch self {
    case .kilograms: return 1
    case .pounds:    return 1
    }
  }
  
  var precision: Double {
    switch self {
    case .kilograms: return 1
    case .pounds:    return 1
    }
  }
  
  var decimals: Int {
    switch self {
    case .kilograms: return 0
    case .pounds:    return 0
    }
  }
}

private extension Units.Length {
  var minimumValue: Double {
    switch self {
    case .centimeters: return 30
    case .feet:        return 30.48 // 1 foot
    }
  }
  
  var maximumValue: Double {
    switch self {
    case .centimeters: return 300
    case .feet:        return 304.8 // 10 feet
    }
  }
  
  var step: Double {
    switch self {
    case .centimeters: return 1
    case .feet:        return 3.048 // 0.1 feet
    }
  }
  
  var precision: Double {
    switch self {
    case .centimeters: return 1
    case .feet:        return 0.1
    }
  }
  
  var decimals: Int {
    switch self {
    case .centimeters: return 0
    case .feet:        return 1
    }
  }
}

private extension Units.Volume {
  var precision: Double {
    switch self {
    case .millilitres: return 1
    case .fluidOunces: return 0.1
    }
  }
  
  var decimals: Int {
    switch self {
    case .millilitres: return 0
    case .fluidOunces: return 1
    }
  }
}

@available(iOS 9.0, *)
private extension Settings.Gender {
  mutating func applyBiologicalSex(_ biologicalSex: HKBiologicalSex) {
    switch biologicalSex {
    case .male:   self = .man
    case .female: self = .woman
    case .notSet: return
    case .other:  return
    }
  }
}
