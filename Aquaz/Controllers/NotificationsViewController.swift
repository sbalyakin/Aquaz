//
//  NotificationsViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 08.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class NotificationsViewController: RevealedTableViewController {
  
  @IBOutlet weak var enableNotificationsCell: UITableViewCell!
  @IBOutlet weak var enableNotificationsSwitch: UISwitch!
  @IBOutlet weak var fromCell: UITableViewCell!
  @IBOutlet weak var toCell: UITableViewCell!
  @IBOutlet weak var intervalCell: UITableViewCell!
  @IBOutlet weak var soundCell: UITableViewCell!
  @IBOutlet weak var useWaterIntakeCell: UITableViewCell!
  @IBOutlet weak var useWaterIntakeSwitch: UISwitch!
  @IBOutlet weak var smartNotificationsCell: UITableViewCell!
  @IBOutlet weak var smartNotificationsSwitch: UISwitch!

  override func viewDidLoad() {
    super.viewDidLoad()

    enableNotificationsCell.accessoryView = enableNotificationsSwitch
    smartNotificationsCell.accessoryView = smartNotificationsSwitch
    useWaterIntakeCell.accessoryView = useWaterIntakeSwitch
    
    initControlsFromSettings()
  }
  
  func initControlsFromSettings() {
    enableNotificationsSwitch.setOn(Settings.sharedInstance.notificationsEnabled.value, animated: false)
    fromCell.detailTextLabel?.text = DateHelper.stringFromTime(Settings.sharedInstance.notificationsFrom.value)
    toCell.detailTextLabel?.text = DateHelper.stringFromTime(Settings.sharedInstance.notificationsTo.value)
    intervalCell.detailTextLabel?.text = stringFromTimeInterval(Settings.sharedInstance.notificationsInterval.value)
    smartNotificationsSwitch.setOn(Settings.sharedInstance.notificationsSmart.value, animated: false)
    useWaterIntakeSwitch.setOn(Settings.sharedInstance.notificationsUseWaterIntake.value, animated: false)
    
    let soundFileName = Settings.sharedInstance.notificationsSound.value
    let soundTitle = soundFileName.stringByDeletingPathExtension.capitalizedString
    soundCell.detailTextLabel?.text = soundTitle
  }
  
  private func stringFromTimeInterval(timeInterval: NSTimeInterval) -> String {
    let overallSeconds = Int(timeInterval)
    let seconds = overallSeconds % 60
    let minutes = (overallSeconds / 60) % 60
    let hours = (overallSeconds / 3600)
    let template = NSLocalizedString("NVC:%u hr %u min", value: "%u hr %u min", comment: "NotificationsViewController: Template string for time interval")
    let result = NSString(format: template, hours, minutes)
    return result
  }

  func updateNotificationsFromSettings() {
    NotificationsHelper.removeAllNotifications()

    if Settings.sharedInstance.notificationsEnabled.value {
      if NotificationsHelper.areLocalNotificationsRegistered() {
        NotificationsHelper.scheduleNotificationsFromSettingsForDate(NSDate())
      } else {
        NotificationsHelper.registerApplicationForLocalNotifications()
      }
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

      case "Sound":
        if let controller = segue.destinationViewController as? NotificationsSoundViewController {
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
