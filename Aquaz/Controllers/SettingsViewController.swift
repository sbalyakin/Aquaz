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
    
    #if AQUAZLITE
    lazy var fullVersionTitle = NSLocalizedString("SVC:Full Version",
      value: "Full Version",
      comment: "SettingsViewController: Table cell title for [Full Version] settings block when Full Version is not purchased yet")
    
    lazy var fullVersionIsPurchasedTitle = NSLocalizedString("SVC:Full Version Is Purchased",
      value: "Full Version Is Purchased",
      comment: "SettingsViewController: Table cell title for [Full Version] settings block when Full Version is purchased")
    #endif
    
    @available(iOS 9.0, *)
    lazy var appleHealthTitle = NSLocalizedString("SVC:Apple Health",
      value: "Apple Health",
      comment: "SettingsViewController: Table title for [Apple Health] cell")
  }

  fileprivate struct Segues {
    static let calculateWaterIntake = "Calculate Water Intake"
    static let showNotifications = "Show Notifications"
    static let showExtraFactors = "Show Extra Factors"
    static let showUnits = "Show Units"
    static let showSupport = "Show Support"
    static let showAppleHealth = "Show Apple Health"
    #if AQUAZLITE
    static let manageFullVersion = "Manage Full Version"
    #endif
  }
  

  fileprivate var volumeObserver: SettingsObserver?
  fileprivate var waterGoalObserver: SettingsObserver?
  
  fileprivate var localizedStrings = LocalyzedStrings()
  
  #if AQUAZLITE
  var fullVersionCell: BasicTableCell!
  #endif
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    UIHelper.applyStyleToViewController(self)
    rightDetailValueColor = StyleKit.settingsTablesValueColor
    rightDetailSelectedValueColor = StyleKit.settingsTablesSelectedValueColor
    
    #if AQUAZLITE
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(fullVersionIsPurchased(_:)),
                                           name: NSNotification.Name(rawValue: GlobalConstants.notificationFullVersionIsPurchased), object: nil)
    #endif

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
        self?.performSegue(withIdentifier: Segues.showExtraFactors, sender: tableCell)
      }
    }
    
    extraFactorsCell.image = ImageHelper.loadImage(.SettingsExtraFactors)

    let recommendationsSection = TableCellsSection()
    recommendationsSection.tableCells = [dailyWaterIntakeCell, extraFactorsCell]
    
    // Units section
    let unitsCell = createBasicTableCell(title: localizedStrings.unitsTitle, accessoryType: .disclosureIndicator)
    
    unitsCell.activationChangedFunction = { [weak self] (tableCell, active) -> () in
      if active {
        self?.performSegue(withIdentifier: Segues.showUnits, sender: tableCell)
      }
    }

    unitsCell.image = ImageHelper.loadImage(.SettingsUnits)

    let unitsSection = TableCellsSection()
    unitsSection.tableCells = [unitsCell]

    // Notifications section
    let notificationsCell = createBasicTableCell(title: localizedStrings.notificationsTitle, accessoryType: .disclosureIndicator)
    
    notificationsCell.activationChangedFunction = { [weak self] (tableCell, active) -> () in
      if active {
        self?.performSegue(withIdentifier: Segues.showNotifications, sender: tableCell)
      }
    }
    
    notificationsCell.image = ImageHelper.loadImage(.SettingsNotifications)
    
    let notificationsSection = TableCellsSection()
    notificationsSection.tableCells = [notificationsCell]
    
    // Support section
    let supportCell = createBasicTableCell(title: localizedStrings.supportTitle, accessoryType: .disclosureIndicator)
    
    supportCell.activationChangedFunction = { [weak self] (tableCell, active) -> () in
        if active {
          self?.performSegue(withIdentifier: Segues.showSupport, sender: tableCell)
        }
    }
    
    supportCell.image = ImageHelper.loadImage(.SettingsFeedback)
    
    let supportSection = TableCellsSection()
    supportSection.tableCells = [supportCell]
    
    #if AQUAZLITE
    // Full Version section
    if Settings.sharedInstance.generalFullVersion.value {
      fullVersionCell = createBasicTableCell(title: localizedStrings.fullVersionIsPurchasedTitle)
    } else {
      fullVersionCell = createBasicTableCell(
        title: localizedStrings.fullVersionTitle,
        accessoryType: .disclosureIndicator)
      
      fullVersionCell.activationChangedFunction = { [weak self] tableCell, active in
        if active {
          self?.performSegue(withIdentifier: Segues.manageFullVersion, sender: tableCell)
        }
      }
    }
    
    fullVersionCell.image = ImageHelper.loadImage(.SettingsFullVersion)
    
    let fullVersionSection = TableCellsSection()
    fullVersionSection.tableCells = [fullVersionCell]
    #endif
    
    // Adding sections
    var sections = [recommendationsSection, unitsSection, notificationsSection, supportSection]

    #if AQUAZLITE
    sections += [fullVersionSection]
    #endif
    
    // Apple Health section
    if #available(iOS 9.0, *) {
      let healthCell = createBasicTableCell(title: localizedStrings.appleHealthTitle, accessoryType: .disclosureIndicator)
      
      healthCell.activationChangedFunction = { [weak self] tableCell, active in
        if active {
          self?.performSegue(withIdentifier: Segues.showAppleHealth, sender: tableCell)
        }
      }
      
      healthCell.image = ImageHelper.loadImage(.SettingsHealthKit)
      
      let healthSection = TableCellsSection()
      healthSection.tableCells = [healthCell]
      
      sections += [healthSection]
    }
    
    return sections
  }
  
  #if AQUAZLITE
  func fullVersionIsPurchased(_ notification: NSNotification) {
    fullVersionCell.title = localizedStrings.fullVersionIsPurchasedTitle
    fullVersionCell.accessoryType = nil
    fullVersionCell.activationChangedFunction = nil
  }
  #endif
  
  fileprivate func stringFromWaterGoal(_ waterGoal: Double) -> String {
    let volumeUnit = Settings.sharedInstance.generalVolumeUnits.value
    let text = Units.sharedInstance.formatMetricAmountToText(metricAmount: waterGoal, unitType: .volume, roundPrecision: volumeUnit.precision, fractionDigits: volumeUnit.decimals, displayUnits: true)
    return text
  }
  
  fileprivate func waterGoalCellWasSelected(_ tableCell: TableCell, active: Bool) {
    if active {
      performSegue(withIdentifier: Segues.calculateWaterIntake, sender: tableCell)
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
