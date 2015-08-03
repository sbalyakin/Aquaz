//
//  WelcomeWizardMetricsViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 04.04.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit
import CoreData

class WelcomeWizardMetricsViewController: OmegaSettingsViewController {

  private struct LocalizedStrings {
    
    lazy var genderTitle = NSLocalizedString("WGVC:Gender", value: "Gender",
      comment: "WaterGoalViewController: Table cell title for [Gender] setting")
    
    lazy var heightTitle = NSLocalizedString("WGVC:Height", value: "Height",
      comment: "WaterGoalViewController: Table cell title for [Height] setting")
    
    lazy var weightTitle = NSLocalizedString("WGVC:Weight", value: "Weight",
      comment: "WaterGoalViewController: Table cell title for [Weight] setting")
    
    lazy var ageTitle = NSLocalizedString("WGVC:Age", value: "Age",
      comment: "WaterGoalViewController: Table cell title for [Age] setting")
    
    lazy var physicalActivityTitle = NSLocalizedString("WGVC:Physical Activity", value: "Physical Activity",
      comment: "WaterGoalViewController: Table cell title for [Physical Activity] setting")
    
    lazy var dailyWaterIntakeTitle = NSLocalizedString("WGVC:Daily Water Intake", value: "Daily Water Intake",
      comment: "WaterGoalViewController: Table cell title for [Daily Water Intake] setting")
    
    lazy var dailyWaterIntakeSectionFooter = NSLocalizedString("The calculated daily water intake is only an estimate. Always take into account your body\'s needs. Please consult your health care provider for advice about a specific medical condition.",
      value: "The calculated daily water intake is only an estimate. Always take into account your body\'s needs. Please consult your health care provider for advice about a specific medical condition.",
      comment: "Footer for section with calculated daily water intake")
    
  }
  
  @IBOutlet weak var descriptionLabel: UILabel!
  
  private var managedObjectContext: NSManagedObjectContext { return CoreDataStack.privateContext }
  
  private var heightObserver: SettingsObserver?
  private var weightObserver: SettingsObserver?
  private var volumeObserver: SettingsObserver?
  
  private var localizedStrings = LocalizedStrings()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    UIHelper.applyStyleToViewController(self)
    rightDetailValueColor = StyleKit.settingsTablesValueColor
    rightDetailSelectedValueColor = StyleKit.settingsTablesSelectedValueColor

    initObserving()
  }

  private func initObserving() {
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
      let newHeight = descriptionLabel.sizeThatFits(CGSize(width: descriptionLabel.frame.width, height: CGFloat.max)).height
      descriptionLabel.frame.size.height = newHeight
      
      let deltaHeight = newHeight - originalHeight
      if deltaHeight != 0 {
        headerView.frame.size.height += deltaHeight
        tableView.tableHeaderView = headerView
        view.layoutIfNeeded()
      }
    }
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    saveWaterGoalToCoreData()
  }

  override func viewDidAppear(animated: Bool) {
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
      pickerTableCellHeight: .Small,
      stringFromValueFunction: WelcomeWizardMetricsViewController.stringFromGender)
    
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
      stringFromValueFunction: WelcomeWizardMetricsViewController.stringFromHeight)
    
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
      stringFromValueFunction: WelcomeWizardMetricsViewController.stringFromWeight)
    
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
      stringFromValueFunction: WelcomeWizardMetricsViewController.stringFromAge)
    
    ageCell.valueChangedFunction = { [weak self] in self?.sourceCellValueChanged($0) }
    
    // Physical activity cell
    physicalActivityCell = createEnumRightDetailTableCell(
      title: localizedStrings.physicalActivityTitle,
      settingsItem: Settings.sharedInstance.userPhysicalActivity,
      pickerTableCellHeight: .Small,
      stringFromValueFunction: WelcomeWizardMetricsViewController.stringFromPhysicalActivity)
    
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

    // Daily Water Intke section
    
    dailyWaterIntakeCell = createTextFieldTableCell(
      title: dailyWaterIntakeTitleFinal, settingsItem:
      Settings.sharedInstance.userDailyWaterIntake,
      valueFromStringFunction: WelcomeWizardMetricsViewController.metricWaterGoalFromString,
      stringFromValueFunction: WelcomeWizardMetricsViewController.stringFromWaterGoal,
      keyboardType: .DecimalPad)
    
    let dailyWaterIntakeSection = TableCellsSection()
    dailyWaterIntakeSection.footerTitle = localizedStrings.dailyWaterIntakeSectionFooter
    dailyWaterIntakeSection.tableCells = [dailyWaterIntakeCell]
    
    return [informationSection, dailyWaterIntakeSection]
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
  
  private func saveWaterGoalToCoreData() {
    managedObjectContext.performBlock {
      WaterGoal.addEntity(
        date: NSDate(),
        baseAmount: self.dailyWaterIntakeCell.value,
        isHotDay: false,
        isHighActivity: false,
        managedObjectContext: self.managedObjectContext)
    }
  }
  
  private func sourceCellValueChanged(tableCell: TableCell) {
    let data = WaterGoalCalculator.Data(physicalActivity: physicalActivityCell.value, gender: genderCell.value, age: ageCell.value, height: heightCell.value, weight: weightCell.value, country: .Average)
    
    let waterGoalAmount = WaterGoalCalculator.calcDailyWaterIntake(data: data)
    
    dailyWaterIntakeCell.value = waterGoalAmount
  }
  
  private var genderCell: RightDetailTableCell<Settings.Gender>!
  private var heightCell: TableCellWithValue<Double>!
  private var weightCell: TableCellWithValue<Double>!
  private var ageCell: TableCellWithValue<Int>!
  private var physicalActivityCell: TableCellWithValue<Settings.PhysicalActivity>!
  private var dailyWaterIntakeCell: TableCellWithValue<Double>!
  
  private let minimumAge = 10
  private let maximumAge = 100
  
  private var originalTableViewContentInset: UIEdgeInsets = UIEdgeInsetsZero
  
}

private extension Units.Weight {
  var minimumValue: Double {
    switch self {
    case Kilograms: return 30
    case Pounds:    return 66
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
