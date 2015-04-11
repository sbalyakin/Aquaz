//
//  SettingsViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 03.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class SettingsViewController: OmegaSettingsViewController {

  private var volumeObserverIdentifier: Int?
  private let numberFormatter = NSNumberFormatter()
  
  private struct Constants {
    static let calculateWaterIntakeSegue = "Calculate Water Intake"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    UIHelper.setupReveal(self)
    UIHelper.applyStyle(self)
    rightDetailValueColor = StyleKit.settingsTablesValueColor
    rightDetailSelectedValueColor = StyleKit.settingsTablesSelectedValueColor
    
    numberFormatter.numberStyle = .PercentStyle
    numberFormatter.maximumFractionDigits = 0
    numberFormatter.multiplier = 100
  }

  deinit {
    if let volumeObserverIdentifier = volumeObserverIdentifier {
      Settings.notificationsSound.removeObserver(volumeObserverIdentifier)
    }
  }

  override func createTableCellsSections() -> [TableCellsSection] {
    let volumeTitle = NSLocalizedString("SVC:Volume", value: "Volume",
      comment: "SettingsViewController: Table cell title for [Volume] setting")

    let weightTitle = NSLocalizedString("SVC:Weight", value: "Weight",
      comment: "SettingsViewController: Table cell title for [Weight] setting")
    
    let heightTitle = NSLocalizedString("SVC:Height", value: "Height",
      comment: "SettingsViewController: Table cell title for [Height] setting")
    
    let waterGoalTitle = NSLocalizedString("SVC:Water Goal", value: "Water Goal",
      comment: "SettingsViewController: Table cell title for [Water Goal] setting")

    let unitsSectionHeader = NSLocalizedString("SVC:Measurements units", value: "Measurements units",
      comment: "SettingsViewController: Header for settings section [Measurements units]")

    let recommendationsSectionHeader = NSLocalizedString("SVC:Recommendations", value: "Recommendations",
      comment: "SettingsViewController: Header for settings section [Recommendations]")

    let extraFactorsSectionHeader = NSLocalizedString("SVC:Extra factors", value: "Extra factors",
      comment: "SettingsViewController: Header for settings section [Extra factors]")

    let highActivitySectionFooter = NSLocalizedString("SVC:Additional water goal related to high activity", value: "Additional water goal related to high activity",
      comment: "SettingsViewController: Footer for high activity section")

    let highActivityTitle = NSLocalizedString("SVC:High Activity", value: "High Activity",
      comment: "SettingsViewController: Table cell title for [High Activity] setting")

    let hotDaySectionFooter = NSLocalizedString("SVC:Additional water goal related to high day temperature", value: "Additional water goal related to high day temperature",
      comment: "SettingsViewController: Footer for hot day section")

    let hotDayTitle = NSLocalizedString("SVC:Hot Day", value: "Hot Day",
      comment: "SettingsViewController: Table cell title for [Hot Day] setting")

    // Measurements section
    let volumeCell = createEnumSegmentedTableCell(
      title: volumeTitle,
      settingsItem: Settings.generalVolumeUnits,
      segmentsWidth: 70)
    
    let weightCell = createEnumSegmentedTableCell(
      title: weightTitle,
      settingsItem: Settings.generalWeightUnits,
      segmentsWidth: 70)
    
    let heightCell = createEnumSegmentedTableCell(
      title: heightTitle,
      settingsItem: Settings.generalHeightUnits,
      segmentsWidth: 70)

    let unitsSection = TableCellsSection()
    unitsSection.headerTitle = unitsSectionHeader
    unitsSection.tableCells = [
      volumeCell,
      weightCell,
      heightCell]
    
    // Water goal section
    let waterGoalCell = createRightDetailTableCell(
      title: waterGoalTitle,
      settingsItem: Settings.userWaterGoal,
      accessoryType: .DisclosureIndicator,
      activationChangedFunction: { [unowned self] in self.waterGoalCellWasSelected($0, active: $1) },
      stringFromValueFunction: { [unowned self] in self.stringFromWaterGoal($0) })
    
    waterGoalCell.image = UIImage(named: "iconWaterDrop")
    
    volumeObserverIdentifier = Settings.generalVolumeUnits.addObserver { value in
      waterGoalCell.readFromExternalStorage()
    }

    let recommendationsSection = TableCellsSection()
    recommendationsSection.headerTitle = recommendationsSectionHeader
    recommendationsSection.tableCells = [waterGoalCell]
    
    // High activity section
    let factorsCollection = DoubleCollection(
      minimumValue: 0.1,
      maximumValue: 1.0,
      step: 0.1)
    
    let highActivityCell = createRangedRightDetailTableCell(
      title: highActivityTitle,
      settingsItem: Settings.generalHighActivityExtraFactor,
      collection: factorsCollection,
      pickerTableCellHeight: .Large,
      stringFromValueFunction: { [unowned self] in self.stringFromFactor($0) })
    
    highActivityCell.image = UIImage(named: "iconHighActivityActive")
    
    let highActivitySection = TableCellsSection()
    highActivitySection.headerTitle = extraFactorsSectionHeader
    highActivitySection.footerTitle = highActivitySectionFooter
    highActivitySection.tableCells = [highActivityCell]
    
    // Hot day section
    let hotDayCell = createRangedRightDetailTableCell(
      title: hotDayTitle,
      settingsItem: Settings.generalHotDayExtraFactor,
      collection: factorsCollection,
      pickerTableCellHeight: .Large,
      stringFromValueFunction: { [unowned self] in self.stringFromFactor($0) })
    
    hotDayCell.image = UIImage(named: "iconHotActive")
    
    let hotDaySection = TableCellsSection()
    hotDaySection.footerTitle = hotDaySectionFooter
    hotDaySection.tableCells = [hotDayCell]
    
    // Adding section
    return [unitsSection, recommendationsSection, highActivitySection, hotDaySection]
  }
  
  private func stringFromFactor(value: Double) -> String {
    return numberFormatter.stringFromNumber(value)!
  }
  
  private func stringFromWaterGoal(waterGoal: Double) -> String {
    let volumeUnit = Settings.generalVolumeUnits.value
    let text = Units.sharedInstance.formatMetricAmountToText(metricAmount: waterGoal, unitType: .Volume, roundPrecision: volumeUnit.precision, decimals: volumeUnit.decimals, displayUnits: true)
    return text
  }
  
  private func waterGoalCellWasSelected(tableCell: TableCell, active: Bool) {
    if active {
      performSegueWithIdentifier(Constants.calculateWaterIntakeSegue, sender: tableCell)
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