//
//  SettingsTableViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 03.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
  
  @IBOutlet weak var revealButton: UIBarButtonItem!
  
  @IBOutlet weak var volume: UISegmentedControl!
  @IBOutlet weak var weight: UISegmentedControl!
  @IBOutlet weak var height: UISegmentedControl!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Getting actual settings
    volume.selectedSegmentIndex = Settings.General.volumeUnits.rawValue
    weight.selectedSegmentIndex = Settings.General.weightUnits.rawValue
    height.selectedSegmentIndex = Settings.General.heightUnits.rawValue
    
    // Additional setup for revealing
    revealButtonSetup()
  }
  
  func revealButtonSetup() {
    if let revealViewController = self.revealViewController() {
      revealButton.target = revealViewController
      revealButton.action = "revealToggle:"
      navigationController!.navigationBar.addGestureRecognizer(revealViewController.panGestureRecognizer())
      view.addGestureRecognizer(revealViewController.panGestureRecognizer())
    }
  }
  
  @IBAction func volumeSettingChanged(sender: UISegmentedControl) {
    Settings.General.volumeUnits = Units.Volume(rawValue: sender.selectedSegmentIndex)!
  }
  
  @IBAction func weightSettingChanged(sender: UISegmentedControl) {
    Settings.General.weightUnits = Units.Weight(rawValue: sender.selectedSegmentIndex)!
  }
  
  @IBAction func heightSettingChanged(sender: UISegmentedControl) {
    Settings.General.heightUnits = Units.Length(rawValue: sender.selectedSegmentIndex)!
  }
}
