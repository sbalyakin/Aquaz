//
//  SettingsViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 03.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class SettingsViewController: OmegaSettingsViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    RevealInitializer.revealButtonSetup(self)
    Styler.viewDidLoad(self)
    
    initTableCells()
  }
  
  private func initTableCells() {
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
    
    let weightCell = createEnumSegmentedTableCell(
      title: weightTitle,
      settingsItem: Settings.sharedInstance.generalWeightUnits,
      segmentsWidth: 70)
    
    let heightCell = createEnumSegmentedTableCell(
      title: heightTitle,
      settingsItem: Settings.sharedInstance.generalHeightUnits,
      segmentsWidth: 70)
    
    let waterGoalCell = createRightDetailTableCell(title: waterGoalTitle, value: Settings.sharedInstance.userWaterGoal.value, accessoryType: .DisclosureIndicator, selectionChangedFunction: waterGoalCellWasSelected, stringFromValueFunction: stringFromWaterGoal)
    
    let unitsSection = TableCellsSection()
    unitsSection.headerTitle = unitsSectionHeader
    unitsSection.tableCells = [
      volumeCell,
      weightCell,
      heightCell]

    let recommendationsSection = TableCellsSection()
    recommendationsSection.headerTitle = recommendationsSectionHeader
    recommendationsSection.tableCells = [waterGoalCell]
    
    tableSections = [unitsSection, recommendationsSection]
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    readTableCellValuesFromExternalStorage()
  }
  
  private func stringFromWaterGoal(waterGoal: Double) -> String {
    let volumeUnit = Settings.sharedInstance.generalVolumeUnits.value
    let text = Units.sharedInstance.formatMetricAmountToText(metricAmount: waterGoal, unitType: .Volume, roundPrecision: volumeUnit.precision, decimals: volumeUnit.decimals, displayUnits: true)
    return text
  }
  
  private func waterGoalCellWasSelected(tableCell: TableCell, selected: Bool) {
    if selected {
      if let waterGoalViewController = storyboard?.instantiateViewControllerWithIdentifier("WaterGoalViewController") as? WaterGoalViewController {
        navigationController?.pushViewController(waterGoalViewController, animated: true)
      } else {
        assert(false)
      }

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