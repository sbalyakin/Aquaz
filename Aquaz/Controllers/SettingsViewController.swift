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
  
  private struct Constants {
    static let calculateWaterIntakeSegue = "Calculate Water Intake"
    static let showNotificationsSegue = "Show Notifications"
    static let showExtraFactorsSegue = "Show Extra Factors"
    static let showUnitsSegue = "Show Units"
    static let showSupportSegue = "Show Support"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    UIHelper.applyStyle(self)
    rightDetailValueColor = StyleKit.settingsTablesValueColor
    rightDetailSelectedValueColor = StyleKit.settingsTablesSelectedValueColor
  }

  deinit {
    if let volumeObserverIdentifier = volumeObserverIdentifier {
      Settings.notificationsSound.removeObserver(volumeObserverIdentifier)
    }
  }

  override func createTableCellsSections() -> [TableCellsSection] {
    let waterGoalTitle = NSLocalizedString("SVC:Water Goal", value: "Water Goal",
      comment: "SettingsViewController: Table cell title for [Water Goal] setting")

    let recommendationsSectionHeader = NSLocalizedString("SVC:Recommendations", value: "Recommendations",
      comment: "SettingsViewController: Header for settings section [Recommendations]")

    let extraFactorsTitle = NSLocalizedString("SVC:Extra Factors", value: "Extra Factors",
      comment: "SettingsViewController: Table cell title for [Extra Factors] setting")

    let unitsTitle = NSLocalizedString("SVC:Units", value: "Units",
      comment: "SettingsViewController: Table cell title for [Units] setting")

    let notificationsTitle = NSLocalizedString("SVC:Notifications", value: "Notifications",
      comment: "SettingsViewController: Table cell title for [Notifications] setting")

    let supportTitle = NSLocalizedString("SVC:Support", value: "Support",
      comment: "SettingsViewController: Table cell title for [Support] setting")

    // Water goal section
    let waterGoalCell = createRightDetailTableCell(
      title: waterGoalTitle,
      settingsItem: Settings.userWaterGoal,
      accessoryType: .DisclosureIndicator,
      activationChangedFunction: { [unowned self] in self.waterGoalCellWasSelected($0, active: $1) },
      stringFromValueFunction: { [unowned self] in self.stringFromWaterGoal($0) })
    
    waterGoalCell.image = UIImage(named: "settingsWater")
    
    volumeObserverIdentifier = Settings.generalVolumeUnits.addObserver { value in
      waterGoalCell.readFromExternalStorage()
    }

    let extraFactorsCell = createBasicTableCell(title: extraFactorsTitle, accessoryType: .DisclosureIndicator) { [unowned self]
      (tableCell, active) -> () in
      if active {
        self.performSegueWithIdentifier(Constants.showExtraFactorsSegue, sender: tableCell)
      }
    }
    
    extraFactorsCell.image = UIImage(named: "settingsExtraFactors")

    let recommendationsSection = TableCellsSection()
    recommendationsSection.headerTitle = recommendationsSectionHeader
    recommendationsSection.tableCells = [waterGoalCell, extraFactorsCell]
    
    // Units section
    let unitsCell = createBasicTableCell(title: unitsTitle, accessoryType: .DisclosureIndicator) { [unowned self]
      (tableCell, active) -> () in
      if active {
        self.performSegueWithIdentifier(Constants.showUnitsSegue, sender: tableCell)
      }
    }

    unitsCell.image = UIImage(named: "settingsUnits")

    let unitsSection = TableCellsSection()
    unitsSection.tableCells = [unitsCell]

    // Notifications section
    let notificationsCell = createBasicTableCell(title: notificationsTitle, accessoryType: .DisclosureIndicator) { [unowned self]
      (tableCell, active) -> () in
      if active {
        self.performSegueWithIdentifier(Constants.showNotificationsSegue, sender: tableCell)
      }
    }
    
    notificationsCell.image = UIImage(named: "settingsNotifications")
    
    let notificationsSection = TableCellsSection()
    notificationsSection.tableCells = [notificationsCell]
    
    // Support section
    let supportCell = createBasicTableCell(title: supportTitle, accessoryType: .DisclosureIndicator) { [unowned self]
        (tableCell, active) -> () in
        if active {
          self.performSegueWithIdentifier(Constants.showSupportSegue, sender: tableCell)
        }
    }
    
    supportCell.image = UIImage(named: "settingsFeedback")
    
    let supportSection = TableCellsSection()
    supportSection.tableCells = [supportCell]
    
    // Adding sections
    return [recommendationsSection, unitsSection, notificationsSection, supportSection]
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