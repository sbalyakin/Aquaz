//
//  UnitsViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 18.04.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class UnitsViewController: OmegaSettingsViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    UIHelper.applyStyle(self)
    rightDetailValueColor = StyleKit.settingsTablesValueColor
    rightDetailSelectedValueColor = StyleKit.settingsTablesSelectedValueColor
  }
  
  override func createTableCellsSections() -> [TableCellsSection] {
    let volumeTitle = NSLocalizedString("UVC:Volume", value: "Volume",
      comment: "UnitsViewController: Table cell title for [Volume] setting")
    
    let weightTitle = NSLocalizedString("UVC:Weight", value: "Weight",
      comment: "UnitsViewController: Table cell title for [Weight] setting")
    
    let heightTitle = NSLocalizedString("UVC:Height", value: "Height",
      comment: "UnitsViewController: Table cell title for [Height] setting")
    
    let volumeCell = createEnumSegmentedTableCell(
      title: volumeTitle,
      settingsItem: Settings.generalVolumeUnits,
      segmentsWidth: 70)
    
    let weightCell = createEnumSegmentedTableCell(
      title: weightTitle,
      settingsItem: Settings.generalWeightUnits,
      segmentsWidth: 70)
    
    let heightCell = createEnumSegmentedTableCell(
      title: heightTitle,
      settingsItem: Settings.generalHeightUnits,
      segmentsWidth: 70)
    
    let unitsSection = TableCellsSection()
    unitsSection.tableCells = [
      volumeCell,
      weightCell,
      heightCell]
    
    return [unitsSection]
  }

}
