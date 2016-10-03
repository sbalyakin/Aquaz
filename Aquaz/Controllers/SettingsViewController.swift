//
//  SettingsViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 03.10.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class SettingsViewController: OmegaSettingsViewController {

  fileprivate struct LocalyzedStrings {
    
    lazy var dailyWaterIntakeTitle: String = NSLocalizedString("SVC:Daily Water Intake",
      value: "Daily Water Intake",
      comment: "SettingsViewController: Table cell title for [Daily Water Intake] settings bloсk")
    
    lazy var specialModesTitle: String = NSLocalizedString("SVC:Special Modes",
      value: "Special Modes",
      comment: "SettingsViewController: Table cell title for [Special Modes] settings block")
    
    lazy var unitsTitle: String = NSLocalizedString("SVC:Measurement Units",
      value: "Measurement Units",
      comment: "SettingsViewController: Table cell title for [Measurement Units] settings block")
    
    lazy var notificationsTitle: String = NSLocalizedString("SVC:Notifications",
      value: "Notifications",
      comment: "SettingsViewController: Table cell title for [Notifications] settings block")
    
    lazy var supportTitle: String = NSLocalizedString("SVC:Support",
      value: "Support",
      comment: "SettingsViewController: Table cell title for [Support] settings block")
    
    @available(iOS 9.0, *)
    lazy var exportToHealthAppTitle: String = NSLocalizedString("SVC:Export to Apple Health",
      value: "Export to Apple Health",
      comment: "SettingsViewController: Table title for [Export to Apple Health] cell")

  }
  
  fileprivate var volumeObserver: SettingsObserver?
  fileprivate var waterGoalObserver: SettingsObserver?
  
  fileprivate var localizedStrings = LocalyzedStrings()
  
  fileprivate struct Constants {
    static let calculateWaterIntakeSegue = "Calculate Water Intake"
    static let showNotificationsSegue = "Show Notifications"
    static let showExtraFactorsSegue = "Show Extra Factors"
    static let showUnitsSegue = "Show Units"
    static let showSupportSegue = "Show Support"
    static let exportToHealthKit = "Export To HealthKit"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    UIHelper.applyStyleToViewController(self)
    rightDetailValueColor = StyleKit.settingsTablesValueColor
    rightDetailSelectedValueColor = StyleKit.settingsTablesSelectedValueColor
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  override func createTableCellsSections() -> [TableCellsSection] {
    // Water goal section
    let dailyWaterIntakeCell = createRightDetailTableCell(
      title: localizedStrings.dailyWaterIntakeTitle,
      settingsItem: Settings.sharedInstance.userDailyWaterIntake,
      stringFromValueFunction: { [weak self] in self?.stringFromWaterGoal($0) ?? "\($0)" },
      accessoryType: .disclosureIndicator)
    
    dailyWaterIntakeCell.activationChangedFunction = { [weak self] in self?.waterGoalCellWasSelected($0, active: $1) }
    dailyWaterIntakeCell.image = ImageHelper.loadImage(.SettingsWater)
    
    volumeObserver = Settings.sharedInstance.generalVolumeUnits.addObserver { _ in
      dailyWaterIntakeCell.readFromExternalStorage()
    }

    waterGoalObserver = Settings.sharedInstance.userDailyWaterIntake.addObserver { _ in
      dailyWaterIntakeCell.readFromExternalStorage()
    }
    
    let extraFactorsCell = createBasicTableCell(title: localizedStrings.specialModesTitle, accessoryType: .disclosureIndicator)
    
    extraFactorsCell.activationChangedFunction = { [weak self] (tableCell, active) -> () in
      if active {
        self?.performSegue(withIdentifier: Constants.showExtraFactorsSegue, sender: tableCell)
      }
    }
    
    extraFactorsCell.image = ImageHelper.loadImage(.SettingsExtraFactors)

    let recommendationsSection = TableCellsSection()
    recommendationsSection.tableCells = [dailyWaterIntakeCell, extraFactorsCell]
    
    // Units section
    let unitsCell = createBasicTableCell(title: localizedStrings.unitsTitle, accessoryType: .disclosureIndicator)
    
    unitsCell.activationChangedFunction = { [weak self] (tableCell, active) -> () in
      if active {
        self?.performSegue(withIdentifier: Constants.showUnitsSegue, sender: tableCell)
      }
    }

    unitsCell.image = ImageHelper.loadImage(.SettingsUnits)

    let unitsSection = TableCellsSection()
    unitsSection.tableCells = [unitsCell]

    // Notifications section
    let notificationsCell = createBasicTableCell(title: localizedStrings.notificationsTitle, accessoryType: .disclosureIndicator)
    
    notificationsCell.activationChangedFunction = { [weak self] (tableCell, active) -> () in
      if active {
        self?.performSegue(withIdentifier: Constants.showNotificationsSegue, sender: tableCell)
      }
    }
    
    notificationsCell.image = ImageHelper.loadImage(.SettingsNotifications)
    
    let notificationsSection = TableCellsSection()
    notificationsSection.tableCells = [notificationsCell]
    
    // Support section
    let supportCell = createBasicTableCell(title: localizedStrings.supportTitle, accessoryType: .disclosureIndicator)
    
    supportCell.activationChangedFunction = { [weak self] (tableCell, active) -> () in
        if active {
          self?.performSegue(withIdentifier: Constants.showSupportSegue, sender: tableCell)
        }
    }
    
    supportCell.image = ImageHelper.loadImage(.SettingsFeedback)
    
    let supportSection = TableCellsSection()
    supportSection.tableCells = [supportCell]
    
    // Adding sections
    var sections = [recommendationsSection, unitsSection, notificationsSection, supportSection]

    // Export to the Health App section
    if #available(iOS 9.0, *) {
      let healthCell = createBasicTableCell(title: localizedStrings.exportToHealthAppTitle, accessoryType: .disclosureIndicator)
      
      healthCell.activationChangedFunction = { [weak self] tableCell, active in
        if active {
          self?.performSegue(withIdentifier: Constants.exportToHealthKit, sender: tableCell)
        }
      }
      
      healthCell.image = ImageHelper.loadImage(.SettingsHealthKit)
      
      let healthSection = TableCellsSection()
      healthSection.tableCells = [healthCell]
      
      sections += [healthSection]
    }
    
    return sections
  }
  
  fileprivate func stringFromWaterGoal(_ waterGoal: Double) -> String {
    let volumeUnit = Settings.sharedInstance.generalVolumeUnits.value
    let text = Units.sharedInstance.formatMetricAmountToText(metricAmount: waterGoal, unitType: .volume, roundPrecision: volumeUnit.precision, decimals: volumeUnit.decimals, displayUnits: true)
    return text
  }
  
  fileprivate func waterGoalCellWasSelected(_ tableCell: TableCell, active: Bool) {
    if active {
      performSegue(withIdentifier: Constants.calculateWaterIntakeSegue, sender: tableCell)
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
