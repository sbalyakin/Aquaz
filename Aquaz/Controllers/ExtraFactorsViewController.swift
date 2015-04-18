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
    let extraFactorsSectionHeader = NSLocalizedString("EFVC:Extra factors", value: "Extra factors",
      comment: "ExtraFactorsViewController: Header for settings section [Extra factors]")
    
    let highActivitySectionFooter = NSLocalizedString("EFVC:Additional water goal related to high activity", value: "Additional water goal related to high activity",
      comment: "ExtraFactorsViewController: Footer for high activity section")
    
    let highActivityTitle = NSLocalizedString("EFVC:High Activity", value: "High Activity",
      comment: "ExtraFactorsViewController: Table cell title for [High Activity] setting")
    
    let hotDaySectionFooter = NSLocalizedString("EFVC:Additional water goal related to high day temperature", value: "Additional water goal related to high day temperature",
      comment: "ExtraFactorsViewController: Footer for hot day section")
    
    let hotDayTitle = NSLocalizedString("EFVC:Hot Day", value: "Hot Day",
      comment: "ExtraFactorsViewController: Table cell title for [Hot Day] setting")
    
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
    
    // Adding sections
    return [highActivitySection, hotDaySection]
  }

  private func stringFromFactor(value: Double) -> String {
    return numberFormatter.stringFromNumber(value)!
  }

}