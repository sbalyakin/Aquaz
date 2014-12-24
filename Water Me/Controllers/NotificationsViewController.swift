//
//  NotificationsViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 08.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class NotificationsViewController: RevealedTableViewController {
  
  @IBOutlet weak var enableNotificationsSwitch: UISwitch!
  @IBOutlet weak var fromCell: UITableViewCell!
  @IBOutlet weak var toCell: UITableViewCell!
  @IBOutlet weak var intervalCell: UITableViewCell!
  @IBOutlet weak var smartNotificationsSwitch: UISwitch!
  @IBOutlet weak var useWaterIntakeSwitch: UISwitch!

  override func viewDidLoad() {
    super.viewDidLoad()
    initControlsFromSettings()
  }
  
  func initControlsFromSettings() {
    enableNotificationsSwitch.setOn(Settings.sharedInstance.notificationsEnabled.value, animated: false)
    fromCell.detailTextLabel?.text = DateHelper.stringFromTime(Settings.sharedInstance.notificationsFrom.value)
    toCell.detailTextLabel?.text = DateHelper.stringFromTime(Settings.sharedInstance.notificationsTo.value)
    intervalCell.detailTextLabel?.text = DateHelper.stringFromTimeInterval(Settings.sharedInstance.notificationsInterval.value)
    smartNotificationsSwitch.setOn(Settings.sharedInstance.notificationsSmart.value, animated: false)
    useWaterIntakeSwitch.setOn(Settings.sharedInstance.notificationsUseWaterIntake.value, animated: false)
  }
  
  func updateNotificationsFromSettings() {
    NotificationsHelper.removeAllNotifications()
    
    if Settings.sharedInstance.notificationsEnabled.value {
      NotificationsHelper.addNotificationsFromSettingsForDate(NSDate())
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let identifier = segue.identifier {
      switch identifier {
      case "From":
        if let controller = segue.destinationViewController as? NotificationsTimePickerViewController {
          controller.mode = .From
          controller.notificationsViewController = self
        } else {
          assert(false)
        }

      case "To":
        if let controller = segue.destinationViewController as? NotificationsTimePickerViewController {
          controller.mode = .To
          controller.notificationsViewController = self
        } else {
          assert(false)
        }

      case "Interval":
        if let controller = segue.destinationViewController as? NotificationsIntervalPickerViewController {
          controller.notificationsViewController = self
        } else {
          assert(false)
        }

      default:
        assert(false)
      }
    }
  }

  @IBAction func enableNotificationsSwitchValueChanged(sender: AnyObject) {
    if enableNotificationsSwitch.on {
      NotificationsHelper.registerApplicationForLocalNotifications()
    }
    
    Settings.sharedInstance.notificationsEnabled.value = enableNotificationsSwitch.on
    updateNotificationsFromSettings()
  }
  
  @IBAction func smartNotificationsSwitchValueChanged(sender: AnyObject) {
    Settings.sharedInstance.notificationsSmart.value = smartNotificationsSwitch.on
    updateNotificationsFromSettings()
  }
  
  @IBAction func useWaterIntakeSwitchValueChanged(sender: AnyObject) {
    Settings.sharedInstance.notificationsUseWaterIntake.value = useWaterIntakeSwitch.on
    updateNotificationsFromSettings()
  }
}
