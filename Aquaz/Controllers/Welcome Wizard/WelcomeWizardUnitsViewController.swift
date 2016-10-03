//
//  WelcomeWizardUnitsViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 04.04.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class WelcomeWizardUnitsViewController: OmegaSettingsViewController {

  @IBOutlet weak var descriptionLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    UIHelper.applyStyleToViewController(self)
    rightDetailValueColor = StyleKit.settingsTablesValueColor
    rightDetailSelectedValueColor = StyleKit.settingsTablesSelectedValueColor
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    if let headerView = tableView.tableHeaderView {
      headerView.setNeedsLayout()
      headerView.layoutIfNeeded()

      // It's ugly way to update header, but unfortunately I've not found any better way.
      let originalHeight = descriptionLabel.frame.height
      let newHeight = descriptionLabel.sizeThatFits(CGSize(width: descriptionLabel.frame.width, height: CGFloat.greatestFiniteMagnitude)).height
      descriptionLabel.frame.size.height = newHeight
      
      let deltaHeight = newHeight - originalHeight
      if deltaHeight != 0 {
        headerView.frame.size.height += deltaHeight
        tableView.tableHeaderView = headerView
        view.layoutIfNeeded()
      }
    }
  }
  
  override func createTableCellsSections() -> [TableCellsSection] {
    let volumeTitle = NSLocalizedString("SVC:Volume", value: "Volume",
      comment: "SettingsViewController: Table cell title for [Volume] setting")
    
    let weightTitle = NSLocalizedString("SVC:Weight", value: "Weight",
      comment: "SettingsViewController: Table cell title for [Weight] setting")
    
    let heightTitle = NSLocalizedString("SVC:Height", value: "Height",
      comment: "SettingsViewController: Table cell title for [Height] setting")
    
    // Measurements section
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
    
    let unitsSection = TableCellsSection()
    unitsSection.tableCells = [
      volumeCell,
      weightCell,
      heightCell]
    
    // Adding section
    return [unitsSection]
  }

}
