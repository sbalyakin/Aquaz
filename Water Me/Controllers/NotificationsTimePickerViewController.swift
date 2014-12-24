//
//  NotificationsTimePickerViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 23.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class NotificationsTimePickerViewController: UIViewController {
  
  @IBOutlet weak var datePicker: UIDatePicker!
  
  var notificationsViewController: NotificationsViewController!
  var mode: Mode!
  
  enum Mode {
    case From, To
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    switch mode! {
    case .From:
      navigationItem.title = "From"
      datePicker.datePickerMode = .Time
      datePicker.setDate(Settings.sharedInstance.notificationsFrom.value, animated: false)
    case .To:
      navigationItem.title = "To"
      datePicker.datePickerMode = .Time
      datePicker.setDate(Settings.sharedInstance.notificationsTo.value, animated: false)
    }
  }
  
  @IBAction func saveToSettings(sender: AnyObject) {
    switch mode! {
    case .From: Settings.sharedInstance.notificationsFrom.value = datePicker.date
    case .To:   Settings.sharedInstance.notificationsTo.value = datePicker.date
    }
    
    notificationsViewController.initControlsFromSettings()
    notificationsViewController.updateNotificationsFromSettings()
    
    navigationController!.popViewControllerAnimated(true)
  }
  
  @IBAction func cancelButtonWasTapped(sender: AnyObject) {
    navigationController!.popViewControllerAnimated(true)
  }
}
