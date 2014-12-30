//
//  SettingsTableViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 03.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class SettingsTableViewController: RevealedTableViewController {
  
  @IBOutlet weak var volumeCell: UITableViewCell!
  @IBOutlet weak var weightCell: UITableViewCell!
  @IBOutlet weak var heightCell: UITableViewCell!
  @IBOutlet weak var waterIntakeCell: UITableViewCell!
  @IBOutlet weak var volumeSegmentedControl: UISegmentedControl!
  @IBOutlet weak var weightSegmentedControl: UISegmentedControl!
  @IBOutlet weak var heightSegmentedControl: UISegmentedControl!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    volumeCell.accessoryView = volumeSegmentedControl
    weightCell.accessoryView = weightSegmentedControl
    heightCell.accessoryView = heightSegmentedControl
    
    // Getting actual settings
    volumeSegmentedControl.selectedSegmentIndex = Settings.sharedInstance.generalVolumeUnits.value.rawValue
    weightSegmentedControl.selectedSegmentIndex = Settings.sharedInstance.generalWeightUnits.value.rawValue
    heightSegmentedControl.selectedSegmentIndex = Settings.sharedInstance.generalHeightUnits.value.rawValue
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    updateWaterIntakeCell()
  }
  
  @IBAction func volumeSettingChanged(sender: UISegmentedControl) {
    Settings.sharedInstance.generalVolumeUnits.value = Units.Volume(rawValue: sender.selectedSegmentIndex)!
    updateWaterIntakeCell()
  }
  
  @IBAction func weightSettingChanged(sender: UISegmentedControl) {
    Settings.sharedInstance.generalWeightUnits.value = Units.Weight(rawValue: sender.selectedSegmentIndex)!
  }
  
  @IBAction func heightSettingChanged(sender: UISegmentedControl) {
    Settings.sharedInstance.generalHeightUnits.value = Units.Length(rawValue: sender.selectedSegmentIndex)!
  }
  
  private func updateWaterIntakeCell() {
    let waterIntake = Settings.sharedInstance.userDailyWaterIntake.value
    let volumeUnit = Settings.sharedInstance.generalVolumeUnits.value
    let title = Units.sharedInstance.formatMetricAmountToText(metricAmount: waterIntake, unitType: .Volume, roundPrecision: volumeUnit.precision, decimals: volumeUnit.decimals, displayUnits: true)
    
    waterIntakeCell.detailTextLabel?.text = title
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