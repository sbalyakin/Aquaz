//
//  ExtraFactorsViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 18.04.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class ExtraFactorsViewController: OmegaSettingsViewController {
  
  private let numberFormatter = NSNumberFormatter()

  override func viewDidLoad() {
    super.viewDidLoad()

    numberFormatter.numberStyle = .PercentStyle
    numberFormatter.maximumFractionDigits = 0
    numberFormatter.multiplier = 100
    
    UIHelper.applyStyle(self)
    rightDetailValueColor = StyleKit.settingsTablesValueColor
    rightDetailSelectedValueColor = StyleKit.settingsTablesSelectedValueColor
  }
  
  override func createTableCellsSections() -> [TableCellsSection] {
    let highActivitySectionFooter = NSLocalizedString(
      "EFVC:Specify an increase in daily water intake when High Activity mode is turned on.",
      value: "Specify an increase in daily water intake when High Activity mode is turned on.",
      comment: "ExtraFactorsViewController: Footer for high activity section")
    
    let highActivityTitle = NSLocalizedString("EFVC:High Activity", value: "High Activity",
      comment: "ExtraFactorsViewController: Table cell title for [High Activity] setting")
    
    let hotWeatherSectionFooter = NSLocalizedString(
      "EFVC:Specify an increase in daily water intake when Hot Weather mode is turned on.",
      value: "Specify an increase in daily water intake when Hot Weather mode is turned on.",
      comment: "ExtraFactorsViewController: Footer for hot weather section")
    
    let hotWeatherTitle = NSLocalizedString("EFVC:Hot Weather", value: "Hot Weather",
      comment: "ExtraFactorsViewController: Table cell title for [Hot Weather] setting")
    
    // High Activity section
    let factorsCollection = DoubleCollection(
      minimumValue: 0.1,
      maximumValue: 1.0,
      step: 0.1)
    
    let highActivityCell = createRangedRightDetailTableCell(
      title: highActivityTitle,
      settingsItem: Settings.sharedInstance.generalHighActivityExtraFactor,
      collection: factorsCollection,
      pickerTableCellHeight: .Large,
      stringFromValueFunction: { [weak self] in self?.stringFromFactor($0) ?? "\($0)" })
    
    highActivityCell.image = ImageHelper.loadImage(.IconHighActivityActive)
    
    let highActivitySection = TableCellsSection()
    highActivitySection.footerTitle = highActivitySectionFooter
    highActivitySection.tableCells = [highActivityCell]
    
    // Hot Weather section
    let hotWeatherCell = createRangedRightDetailTableCell(
      title: hotWeatherTitle,
      settingsItem: Settings.sharedInstance.generalHotDayExtraFactor,
      collection: factorsCollection,
      pickerTableCellHeight: .Large,
      stringFromValueFunction: { [weak self] in self?.stringFromFactor($0) ?? "\($0)" })
    
    hotWeatherCell.image = ImageHelper.loadImage(.IconHotWeatherActive)
    
    let hotWeatherSection = TableCellsSection()
    hotWeatherSection.footerTitle = hotWeatherSectionFooter
    hotWeatherSection.tableCells = [hotWeatherCell]
    
    // Adding sections
    return [highActivitySection, hotWeatherSection]
  }

  private func stringFromFactor(value: Double) -> String {
    return numberFormatter.stringFromNumber(value)!
  }

}