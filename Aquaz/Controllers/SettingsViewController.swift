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
  private var fullVersionObserverIdentifier: Int?
  
  private struct Constants {
    static let calculateWaterIntakeSegue = "Calculate Water Intake"
    static let showNotificationsSegue = "Show Notifications"
    static let showExtraFactorsSegue = "Show Extra Factors"
    static let showUnitsSegue = "Show Units"
    static let showSupportSegue = "Show Support"
    static let manageFullVersionSegue = "Manage Full Version"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    UIHelper.applyStyle(self)
    rightDetailValueColor = StyleKit.settingsTablesValueColor
    rightDetailSelectedValueColor = StyleKit.settingsTablesSelectedValueColor
  }

  deinit {
    if let volumeObserverIdentifier = volumeObserverIdentifier {
      Settings.generalVolumeUnits.removeObserver(volumeObserverIdentifier)
    }

    if let fullVersionObserverIdentifier = fullVersionObserverIdentifier {
      Settings.generalVolumeUnits.removeObserver(fullVersionObserverIdentifier)
    }
  }

  override func createTableCellsSections() -> [TableCellsSection] {
    let dailyWaterIntakeTitle = NSLocalizedString("SVC:Daily Water Intake", value: "Daily Water Intake",
      comment: "SettingsViewController: Table cell title for [Daily Water Intake] settings blok")

    let specialModesTitle = NSLocalizedString("SVC:Special Modes", value: "Special Modes",
      comment: "SettingsViewController: Table cell title for [Special Modes] settings block")

    let unitsTitle = NSLocalizedString("SVC:Measurement Units", value: "Measurement Units",
      comment: "SettingsViewController: Table cell title for [Meathurement Units] settings block")

    let notificationsTitle = NSLocalizedString("SVC:Notifications", value: "Notifications",
      comment: "SettingsViewController: Table cell title for [Notifications] settings block")

    let supportTitle = NSLocalizedString("SVC:Support", value: "Support",
      comment: "SettingsViewController: Table cell title for [Support] settings block")

    let fullVersionTitle = NSLocalizedString("SVC:Full Version", value: "Full Version",
      comment: "SettingsViewController: Table cell title for [Full Version] settings block when Full Version is not purchased yet")
    
    let fullVersionIsPurchasedTitle = NSLocalizedString("SVC:Full Version Is Purchased", value: "Full Version Is Purchased",
      comment: "SettingsViewController: Table cell title for [Full Version] settings block when Full Version is purchased")

    // Water goal section
    let dailyWaterIntakeCell = createRightDetailTableCell(
      title: dailyWaterIntakeTitle,
      settingsItem: Settings.userWaterGoal,
      accessoryType: .DisclosureIndicator,
      activationChangedFunction: { [unowned self] in self.waterGoalCellWasSelected($0, active: $1) },
      stringFromValueFunction: { [unowned self] in self.stringFromWaterGoal($0) })
    
    dailyWaterIntakeCell.image = UIImage(named: "settingsWater")
    
    volumeObserverIdentifier = Settings.generalVolumeUnits.addObserver { value in
      dailyWaterIntakeCell.readFromExternalStorage()
    }

    let extraFactorsCell = createBasicTableCell(title: specialModesTitle, accessoryType: .DisclosureIndicator) { [unowned self]
      (tableCell, active) -> () in
      if active {
        self.performSegueWithIdentifier(Constants.showExtraFactorsSegue, sender: tableCell)
      }
    }
    
    extraFactorsCell.image = UIImage(named: "settingsExtraFactors")

    let recommendationsSection = TableCellsSection()
    recommendationsSection.tableCells = [dailyWaterIntakeCell, extraFactorsCell]
    
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
    
    // Full Version section
    let fullVersionCellDidActivateFunction = { (tableCell: TableCell, active: Bool) -> () in
      if active {
        self.performSegueWithIdentifier(Constants.manageFullVersionSegue, sender: tableCell)
      }
    }

    let fullVersionCell: BasicTableCell
    
    if Settings.generalFullVersion.value {
      fullVersionCell = createBasicTableCell(title: fullVersionIsPurchasedTitle)
    } else {
      fullVersionCell = createBasicTableCell(
        title: fullVersionTitle,
        accessoryType: .DisclosureIndicator,
        activationChangedFunction: fullVersionCellDidActivateFunction)
    }
    
    fullVersionObserverIdentifier = Settings.generalFullVersion.addObserver { fullVersion in
      if fullVersion {
        fullVersionCell.title = fullVersionIsPurchasedTitle
        fullVersionCell.accessoryType = nil
        fullVersionCell.tableCellDidActivateFunction = nil
      } else {
        fullVersionCell.title = fullVersionTitle
        fullVersionCell.accessoryType = .DisclosureIndicator
        fullVersionCell.tableCellDidActivateFunction = fullVersionCellDidActivateFunction
      }
    }

    fullVersionCell.image = UIImage(named: "settingsFullVersion")

    let fullVersionSection = TableCellsSection()
    fullVersionSection.tableCells = [fullVersionCell]
    
    // Adding sections
    return [recommendationsSection, unitsSection, notificationsSection, supportSection, fullVersionSection]
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