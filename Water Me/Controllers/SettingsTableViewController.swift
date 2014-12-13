//
//  SettingsTableViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 03.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class SettingsTableViewController: RevealedTableViewController {
  
  @IBOutlet weak var volume: UISegmentedControl!
  @IBOutlet weak var weight: UISegmentedControl!
  @IBOutlet weak var height: UISegmentedControl!
  @IBOutlet weak var waterIntakeCell: UITableViewCell!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Getting actual settings
    volume.selectedSegmentIndex = Settings.sharedInstance.generalVolumeUnits.value.rawValue
    weight.selectedSegmentIndex = Settings.sharedInstance.generalWeightUnits.value.rawValue
    height.selectedSegmentIndex = Settings.sharedInstance.generalHeightUnits.value.rawValue
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