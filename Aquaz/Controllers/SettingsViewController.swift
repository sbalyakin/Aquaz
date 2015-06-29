//
//  SettingsViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 03.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class SettingsViewController: OmegaSettingsViewController {

  private struct LocalyzedStrings {
    
    lazy var dailyWaterIntakeTitle = NSLocalizedString("SVC:Daily Water Intake",
      value: "Daily Water Intake",
      comment: "SettingsViewController: Table cell title for [Daily Water Intake] settings bloсk")
    
    lazy var specialModesTitle = NSLocalizedString("SVC:Special Modes",
      value: "Special Modes",
      comment: "SettingsViewController: Table cell title for [Special Modes] settings block")
    
    lazy var unitsTitle = NSLocalizedString("SVC:Measurement Units",
      value: "Measurement Units",
      comment: "SettingsViewController: Table cell title for [Measurement Units] settings block")
    
    lazy var notificationsTitle = NSLocalizedString("SVC:Notifications",
      value: "Notifications",
      comment: "SettingsViewController: Table cell title for [Notifications] settings block")
    
    lazy var supportTitle = NSLocalizedString("SVC:Support",
      value: "Support",
      comment: "SettingsViewController: Table cell title for [Support] settings block")
    
    lazy var fullVersionTitle = NSLocalizedString("SVC:Full Version",
      value: "Full Version",
      comment: "SettingsViewController: Table cell title for [Full Version] settings block when Full Version is not purchased yet")
    
    lazy var fullVersionIsPurchasedTitle = NSLocalizedString("SVC:Full Version Is Purchased",
      value: "Full Version Is Purchased",
      comment: "SettingsViewController: Table cell title for [Full Version] settings block when Full Version is purchased")
    
  }
  
  private var volumeObserverIdentifier: Int?
  private var waterGoalObserverIdentifier: Int?
  
  private var localizedStrings = LocalyzedStrings()
  
  var fullVersionCell: BasicTableCell!

  
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
    
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "fullVersionIsPurchased:",
      name: GlobalConstants.notificationFullVersionIsPurchased, object: nil)
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)

    if let volumeObserverIdentifier = volumeObserverIdentifier {
      Settings.generalVolumeUnits.removeObserver(volumeObserverIdentifier)
    }

    if let waterGoalObserverIdentifier = waterGoalObserverIdentifier {
      Settings.generalVolumeUnits.removeObserver(waterGoalObserverIdentifier)
    }
  }

  override func createTableCellsSections() -> [TableCellsSection] {
    // Water goal section
    let dailyWaterIntakeCell = createRightDetailTableCell(
      title: localizedStrings.dailyWaterIntakeTitle,
      settingsItem: Settings.userDailyWaterIntake,
      accessoryType: .DisclosureIndicator,
      activationChangedFunction: { [weak self] in self?.waterGoalCellWasSelected($0, active: $1) },
      stringFromValueFunction: { [weak self] in self?.stringFromWaterGoal($0) ?? "\($0)" })
    
    dailyWaterIntakeCell.image = ImageHelper.loadImage(.SettingsWater)
    
    volumeObserverIdentifier = Settings.generalVolumeUnits.addObserver { _ in
      dailyWaterIntakeCell.readFromExternalStorage()
    }

    waterGoalObserverIdentifier = Settings.userDailyWaterIntake.addObserver { _ in
      dailyWaterIntakeCell.readFromExternalStorage()
    }
    
    let extraFactorsCell = createBasicTableCell(title: localizedStrings.specialModesTitle, accessoryType: .DisclosureIndicator) { [weak self]
      (tableCell, active) -> () in
      if active {
        self?.performSegueWithIdentifier(Constants.showExtraFactorsSegue, sender: tableCell)
      }
    }
    
    extraFactorsCell.image = ImageHelper.loadImage(.SettingsExtraFactors)

    let recommendationsSection = TableCellsSection()
    recommendationsSection.tableCells = [dailyWaterIntakeCell, extraFactorsCell]
    
    // Units section
    let unitsCell = createBasicTableCell(title: localizedStrings.unitsTitle, accessoryType: .DisclosureIndicator) { [weak self]
      (tableCell, active) -> () in
      if active {
        self?.performSegueWithIdentifier(Constants.showUnitsSegue, sender: tableCell)
      }
    }

    unitsCell.image = ImageHelper.loadImage(.SettingsUnits)

    let unitsSection = TableCellsSection()
    unitsSection.tableCells = [unitsCell]

    // Notifications section
    let notificationsCell = createBasicTableCell(title: localizedStrings.notificationsTitle, accessoryType: .DisclosureIndicator) { [weak self]
      (tableCell, active) -> () in
      if active {
        self?.performSegueWithIdentifier(Constants.showNotificationsSegue, sender: tableCell)
      }
    }
    
    notificationsCell.image = ImageHelper.loadImage(.SettingsNotifications)
    
    let notificationsSection = TableCellsSection()
    notificationsSection.tableCells = [notificationsCell]
    
    // Support section
    let supportCell = createBasicTableCell(title: localizedStrings.supportTitle, accessoryType: .DisclosureIndicator) { [weak self]
        (tableCell, active) -> () in
        if active {
          self?.performSegueWithIdentifier(Constants.showSupportSegue, sender: tableCell)
        }
    }
    
    supportCell.image = ImageHelper.loadImage(.SettingsFeedback)
    
    let supportSection = TableCellsSection()
    supportSection.tableCells = [supportCell]
    
    // Full Version section
    if Settings.generalFullVersion.value {
      fullVersionCell = createBasicTableCell(title: localizedStrings.fullVersionIsPurchasedTitle)
    } else {
      fullVersionCell = createBasicTableCell(
        title: localizedStrings.fullVersionTitle,
        accessoryType: .DisclosureIndicator) { [weak self] tableCell, active in
          if active {
            self?.performSegueWithIdentifier(Constants.manageFullVersionSegue, sender: tableCell)
          }
        }
    }
    
    fullVersionCell.image = ImageHelper.loadImage(.SettingsFullVersion)

    let fullVersionSection = TableCellsSection()
    fullVersionSection.tableCells = [fullVersionCell]
    
    // Adding sections
    return [recommendationsSection, unitsSection, notificationsSection, supportSection, fullVersionSection]
  }
  
  func fullVersionIsPurchased(notification: NSNotification) {
    fullVersionCell.title = localizedStrings.fullVersionIsPurchasedTitle
    fullVersionCell.accessoryType = nil
    fullVersionCell.tableCellDidActivateFunction = nil
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