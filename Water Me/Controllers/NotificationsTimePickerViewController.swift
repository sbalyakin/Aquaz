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
    
    let fromDate = Settings.sharedInstance.notificationsFrom.value
    let toDate = Settings.sharedInstance.notificationsTo.value
    
    switch mode! {
    case .From:
      navigationItem.title = NSLocalizedString("NTPVC:From", value: "From", comment: "NotificationsTimePickerViewController: Navigation item title for choosing [From] time")
      datePicker.datePickerMode = .Time
      datePicker.maximumDate = toDate
      datePicker.setDate(fromDate, animated: false)
    case .To:
      navigationItem.title = NSLocalizedString("NTPVC:To", value: "To", comment: "NotificationsTimePickerViewController: Navigation item title for choosing [To] time")
      datePicker.datePickerMode = .Time
      datePicker.minimumDate = fromDate
      datePicker.setDate(toDate, animated: false)
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
