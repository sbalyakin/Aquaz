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
    volume.selectedSegmentIndex = Settings.General.isMetricVolume ? 0 : 1
    weight.selectedSegmentIndex = Settings.General.isMetricWeight ? 0 : 1
    height.selectedSegmentIndex = Settings.General.isMetricHeight ? 0 : 1
    
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
    Settings.General.isMetricVolume = sender.selectedSegmentIndex == 0
  }
  
  @IBAction func weightSettingChanged(sender: UISegmentedControl) {
    Settings.General.isMetricWeight = sender.selectedSegmentIndex == 0
  }
  
  @IBAction func heightSettingChanged(sender: UISegmentedControl) {
    Settings.General.isMetricHeight = sender.selectedSegmentIndex == 0
  }
}
