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
      "EFVC:Specify daily water intake increasing when High Physical Activity mode is turned on.",
      value: "Specify daily water intake increasing when High Physical Activity mode is turned on.",
      comment: "ExtraFactorsViewController: Footer for high physical activity section")
    
    let highActivityTitle = NSLocalizedString("EFVC:High Physical Activity", value: "High Physical Activity",
      comment: "ExtraFactorsViewController: Table cell title for [High Physical Activity] setting")
    
    let hotWeatherSectionFooter = NSLocalizedString(
      "EFVC:Specify daily water intake increasing when Hot Weather mode is turned on.",
      value: "Specify daily water intake increasing when Hot Weather mode is turned on.",
      comment: "ExtraFactorsViewController: Footer for hot weather section")
    
    let hotWeatherTitle = NSLocalizedString("EFVC:Hot Weather", value: "Hot Weather",
      comment: "ExtraFactorsViewController: Table cell title for [Hot Weather] setting")
    
    // High Physical Activity section
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
    highActivitySection.footerTitle = highActivitySectionFooter
    highActivitySection.tableCells = [highActivityCell]
    
    // Hot Weather section
    let hotWeatherCell = createRangedRightDetailTableCell(
      title: hotWeatherTitle,
      settingsItem: Settings.generalHotDayExtraFactor,
      collection: factorsCollection,
      pickerTableCellHeight: .Large,
      stringFromValueFunction: { [unowned self] in self.stringFromFactor($0) })
    
    hotWeatherCell.image = UIImage(named: "iconHotActive")
    
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