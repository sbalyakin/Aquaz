//
//  SettingsViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 03.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class SettingsViewController: OmegaSettingsViewController {

  private var waterGoalCell: TableCell!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    RevealInitializer.revealButtonSetup(self)
    Styler.viewDidLoad(self)
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    readTableCellValuesFromExternalStorage()
  }

  override func createTableCellsSections() -> [TableCellsSection] {
    let volumeTitle = NSLocalizedString("SVC:Volume", value: "Volume",
      comment: "SettingsViewController: Table cell title for [Volume] setting")

    let weightTitle = NSLocalizedString("SVC:Weight", value: "Weight",
      comment: "SettingsViewController: Table cell title for [Weight] setting")
    
    let heightTitle = NSLocalizedString("SVC:Height", value: "Height",
      comment: "SettingsViewController: Table cell title for [Height] setting")
    
    let waterGoalTitle = NSLocalizedString("SVC:Water goal", value: "Water goal",
      comment: "SettingsViewController: Table cell title for [Water goal] setting")

    let unitsSectionHeader = NSLocalizedString("SVC:Measurements units", value: "Measurements units",
      comment: "SettingsViewController: Header for settings section [Measurements units]")

    let recommendationsSectionHeader = NSLocalizedString("SVC:Recommendations", value: "Recommendations",
      comment: "SettingsViewController: Header for settings section [Recommendations]")

    let volumeCell = createEnumSegmentedTableCell(
      title: volumeTitle,
      settingsItem: Settings.sharedInstance.generalVolumeUnits,
      segmentsWidth: 70)
    volumeCell.valueChangedFunction = volumeUnitDidChange

    
    let weightCell = createEnumSegmentedTableCell(
      title: weightTitle,
      settingsItem: Settings.sharedInstance.generalWeightUnits,
      segmentsWidth: 70)
    
    let heightCell = createEnumSegmentedTableCell(
      title: heightTitle,
      settingsItem: Settings.sharedInstance.generalHeightUnits,
      segmentsWidth: 70)
    
    waterGoalCell = createRightDetailTableCell(title: waterGoalTitle, settingsItem: Settings.sharedInstance.userWaterGoal, accessoryType: .DisclosureIndicator, activationChangedFunction: waterGoalCellWasSelected, stringFromValueFunction: stringFromWaterGoal)
    
    let unitsSection = TableCellsSection()
    unitsSection.headerTitle = unitsSectionHeader
    unitsSection.tableCells = [
      volumeCell,
      weightCell,
      heightCell]

    let recommendationsSection = TableCellsSection()
    recommendationsSection.headerTitle = recommendationsSectionHeader
    recommendationsSection.tableCells = [waterGoalCell]
    
    return [unitsSection, recommendationsSection]
  }
  
  private func volumeUnitDidChange(tableCell: TableCell) {
    waterGoalCell?.readFromExternalStorage()
  }
  
  private func stringFromWaterGoal(waterGoal: Double) -> String {
    let volumeUnit = Settings.sharedInstance.generalVolumeUnits.value
    let text = Units.sharedInstance.formatMetricAmountToText(metricAmount: waterGoal, unitType: .Volume, roundPrecision: volumeUnit.precision, decimals: volumeUnit.decimals, displayUnits: true)
    return text
  }
  
  private func waterGoalCellWasSelected(tableCell: TableCell, active: Bool) {
    if !active {
      return
    }
    
    if let waterGoalViewController: WaterGoalViewController = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: "WaterGoalViewController") {
      navigationController?.pushViewController(waterGoalViewController, animated: true)
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