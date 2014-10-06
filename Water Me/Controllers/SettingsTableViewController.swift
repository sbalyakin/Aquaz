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
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    
    
    // Additional setup for revealing
    revealButtonSetup()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func revealButtonSetup() {
    if let revealViewController = self.revealViewController() {
      revealButton.target = revealViewController
      revealButton.action = "revealToggle:"
      navigationController!.navigationBar.addGestureRecognizer(revealViewController.panGestureRecognizer())
      view.addGestureRecognizer(revealViewController.panGestureRecognizer())
    }
  }
  
}
