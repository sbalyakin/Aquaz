//
//  NotificationsViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 08.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

extension String: Printable {
  public var description: String {
    return self
  }
}

class NotificationsViewController: OmegaSettingsViewController {
  
  private var soundCell: TableCell!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    RevealInitializer.revealButtonSetup(self)
    Styler.viewDidLoad(self)
  }
  
  override func createTableCellsSections() -> [TableCellsSection] {
    let enableNotificationsTitle = NSLocalizedString("NVC:Enable notifications", value: "Enable notifications",
      comment: "NotificationsViewController: Title for [Enable notification] setting")

    let fromTitle = NSLocalizedString("NVC:From", value: "From",
      comment: "NotificationsViewController: Title for [From] setting")

    let toTitle = NSLocalizedString("NVC:To", value: "To",
      comment: "NotificationsViewController: Title for [To] setting")
    
    let intervalTitle = NSLocalizedString("NVC:Interval", value: "Interval",
      comment: "NotificationsViewController: Title for [Interval] setting")

    let intervalHourTitle = NSLocalizedString("NVC:hr", value: "hr",
      comment: "NotificationsViewController: contraction for hour")

    let intervalMinuteTitle = NSLocalizedString("NVC:min", value: "min",
      comment: "NotificationsViewController: contraction for minute")

    let soundTitle = NSLocalizedString("NVC:Sound", value: "Sound",
      comment: "NotificationsViewController: Title for [Sound] setting")
    
    let smartNotificationsTitle = NSLocalizedString("NVC:Smart notifications", value: "Smart notifications",
      comment: "NotificationsViewController: Title for [Smart notifications] setting")
    
    let useWaterIntakeTitle = NSLocalizedString("NVC:Use water intake", value: "Use water intake",
      comment: "NotificationsViewController: Title for [Use water intake] setting")
    
    let smartNotificationsSectionFooter = NSLocalizedString(
      "NVC:Turn smart notifications on and notifications will be shown not earlier than specified interval after the last intake",
      value: "Turn smart notifications on and notifications will be shown not earlier than specified interval after the last intake",
      comment: "NotificationsViewController: Footer text for [Smart notifications] section")
    
    let useWaterIntakeSectionFooter = NSLocalizedString("NVC:Do not notify if daily water intake is reached",
      value: "Do not notify if daily water intake is reached",
      comment: "NotificationsViewController: Footer text for [Use water intake] section")
    
    // Main section
    
    let enableNotificationsCell = createSwitchTableCell(title: enableNotificationsTitle, settingsItem: Settings.sharedInstance.notificationsEnabled)
    enableNotificationsCell.valueChangedFunction = tableCellValueAffectNotificationsDidChange
    
    let fromCell = createDateRightDetailTableCell(title: fromTitle, settingsItem: Settings.sharedInstance.notificationsFrom, datePickerMode: .Time, minimumDate: nil, maximumDate: nil, height: .Large, stringFromValueFunction: timeStringFromDate)
    fromCell.valueChangedFunction = tableCellValueAffectNotificationsDidChange

    let toCell = createDateRightDetailTableCell(title: toTitle, settingsItem: Settings.sharedInstance.notificationsTo, datePickerMode: .Time, minimumDate: nil, maximumDate: nil, height: .Large, stringFromValueFunction: timeStringFromDate)
    toCell.valueChangedFunction = tableCellValueAffectNotificationsDidChange
    
    let timeComponents = [
      TimeIntervalPickerTableCellComponent(calendarUnit: NSCalendarUnit.CalendarUnitHour, minValue: 1, maxValue: 6, step: 1, title: intervalHourTitle, width: nil),
      TimeIntervalPickerTableCellComponent(calendarUnit: NSCalendarUnit.CalendarUnitMinute, minValue: 0, maxValue: 59, step: 5, title: intervalMinuteTitle, width: nil)]
    
    let intervalCell = createTimeIntervalRightDetailTableCell(title: intervalTitle, settingsItem: Settings.sharedInstance.notificationsInterval, timeComponents: timeComponents, height: .Large, stringFromValueFunction: stringFromTimeInterval)
    intervalCell.valueChangedFunction = tableCellValueAffectNotificationsDidChange
  
    let soundCell = createRightDetailTableCell(title: soundTitle, settingsItem: Settings.sharedInstance.notificationsSound, accessoryType: UITableViewCellAccessoryType.DisclosureIndicator, activationChangedFunction: soundTableCellDidActivate, stringFromValueFunction: stringFromSoundFileName)
    fromCell.valueChangedFunction = tableCellValueAffectNotificationsDidChange
    self.soundCell = soundCell
    
    let mainSection = TableCellsSection()
    mainSection.tableCells = [
      enableNotificationsCell,
      fromCell,
      toCell,
      intervalCell,
      soundCell]
    
    // Smart notifications section
    
    let smartNotificationsCell = createSwitchTableCell(title: smartNotificationsTitle, settingsItem: Settings.sharedInstance.notificationsSmart)
    
    let smartNotificationsSection = TableCellsSection()
    smartNotificationsSection.footerTitle = smartNotificationsSectionFooter
    smartNotificationsSection.tableCells = [smartNotificationsCell]
    
    // Use water intake section
    
    let useWaterIntakeCell = createSwitchTableCell(title: useWaterIntakeTitle, settingsItem: Settings.sharedInstance.notificationsUseWaterIntake)
    
    let useWaterIntakeSection = TableCellsSection()
    useWaterIntakeSection.footerTitle = useWaterIntakeSectionFooter
    useWaterIntakeSection.tableCells = [useWaterIntakeCell]
    
    return [mainSection, smartNotificationsSection, useWaterIntakeSection]
  }
  
  private func stringFromTimeInterval(timeInterval: NSTimeInterval) -> String {
    let overallSeconds = Int(timeInterval)
    let minutes = (overallSeconds / 60) % 60
    let hours = (overallSeconds / 3600)
    let template = NSLocalizedString("NVC:%u hr %u min", value: "%u hr %u min", comment: "NotificationsViewController: Template string for time interval")
    let result = NSString(format: template, hours, minutes)
    return result as! String
  }
  
  private func timeStringFromDate(date: NSDate) -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.timeStyle = .ShortStyle
    dateFormatter.dateStyle = .NoStyle
    return dateFormatter.stringFromDate(date)
  }
  
  private func stringFromSoundFileName(filename: String) -> String {
    return filename.stringByDeletingPathExtension.capitalizedString
  }
  
  private func soundTableCellDidActivate(tableCell: TableCell, active: Bool) {
    if active {
      if let controller = storyboard?.instantiateViewControllerWithIdentifier("NotificationsSoundViewController") as? NotificationsSoundViewController {
        controller.notificationsViewController = self
        navigationController?.pushViewController(controller, animated: true)
      } else {
        assert(false)
      }
    }
  }

  private func tableCellValueAffectNotificationsDidChange(tableCell: TableCell) {
    recreateNotifications()
  }

  func recreateNotifications() {
    println("recreateNotifications")
    
    NotificationsHelper.removeAllNotifications()

    if Settings.sharedInstance.notificationsEnabled.value {
      if NotificationsHelper.areLocalNotificationsRegistered() {
        NotificationsHelper.scheduleNotificationsFromSettingsForDate(NSDate())
      } else {
        NotificationsHelper.registerApplicationForLocalNotifications()
      }
    }
  }
  
}
