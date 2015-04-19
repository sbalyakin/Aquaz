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
  
  private var soundObserverIdentifier: Int?
  
  private struct Constants {
    static let chooseSoundSegue = "Choose Sound"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    UIHelper.applyStyle(self)
    rightDetailValueColor = StyleKit.settingsTablesValueColor
    rightDetailSelectedValueColor = StyleKit.settingsTablesSelectedValueColor
  }
  
  deinit {
    if let soundObserverIdentifier = soundObserverIdentifier {
      Settings.notificationsSound.removeObserver(soundObserverIdentifier)
    }
  }

  override func createTableCellsSections() -> [TableCellsSection] {
    let enableNotificationsTitle = NSLocalizedString("NVC:Enable Notifications", value: "Enable Notifications",
      comment: "NotificationsViewController: Title for [Enable Notification] setting")

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

    let soundTitle = NSLocalizedString("NVC:Notification Sound", value: "Notification Sound",
      comment: "NotificationsViewController: Title for [Notification Sound] setting")
    
    let smartNotificationsTitle = NSLocalizedString("NVC:Smart Notifications", value: "Smart Notifications",
      comment: "NotificationsViewController: Title for [Smart Notifications] setting")
    
    let limitNotificationsTitle = NSLocalizedString("NVC:Limit Notifications", value: "Limit Notifications",
      comment: "NotificationsViewController: Title for [Limit Notifications] setting")
    
    // TODO: move to a localization file
    // "Включите режим Умные Оповещения чтобы откладывать оповещения, учитывая время употребления напитков."
    
    let smartNotificationsSectionFooter = NSLocalizedString(
      "NVC:Enable to snooze notifications taking into account time of drink intakes.",
      value: "Enable to snooze notifications taking into account time of drink intakes.",
      comment: "NotificationsViewController: Footer text for [Smart Notifications] section")
    
    let limitNotificationsSectionFooter = NSLocalizedString("NVC:When enabled, notifications will not be shown if you already drink your daily water intake.",
      value: "When enabled, notifications will not be shown if you already drink your daily water intake.",
      comment: "NotificationsViewController: Footer text for [Limit Notifications] section")
    
    // General section
    
    let enableNotificationsCell = createSwitchTableCell(
      title: enableNotificationsTitle,
      settingsItem: Settings.notificationsEnabled)
    
    enableNotificationsCell.valueChangedFunction = NotificationsViewController.tableCellValueAffectNotificationsDidChange
    
    let fromCell = createDateRightDetailTableCell(
      title: fromTitle,
      settingsItem: Settings.notificationsFrom,
      datePickerMode: .Time,
      minimumDate: nil,
      maximumDate: nil,
      height: .Large,
      stringFromValueFunction: NotificationsViewController.timeStringFromDate)
    
    fromCell.valueChangedFunction = NotificationsViewController.tableCellValueAffectNotificationsDidChange

    let toCell = createDateRightDetailTableCell(
      title: toTitle,
      settingsItem: Settings.notificationsTo,
      datePickerMode: .Time,
      minimumDate: nil,
      maximumDate: nil,
      height: .Large,
      stringFromValueFunction: NotificationsViewController.timeStringFromDate)
    
    toCell.valueChangedFunction = NotificationsViewController.tableCellValueAffectNotificationsDidChange
    
    let timeComponents = [
      TimeIntervalPickerTableCellComponent(calendarUnit: NSCalendarUnit.CalendarUnitHour, minValue: 1, maxValue: 6, step: 1, title: intervalHourTitle, width: nil),
      TimeIntervalPickerTableCellComponent(calendarUnit: NSCalendarUnit.CalendarUnitMinute, minValue: 0, maxValue: 59, step: 5, title: intervalMinuteTitle, width: nil)]
    
    let intervalCell = createTimeIntervalRightDetailTableCell(
      title: intervalTitle,
      settingsItem: Settings.notificationsInterval,
      timeComponents: timeComponents,
      height: .Large,
      stringFromValueFunction: NotificationsViewController.stringFromTimeInterval)
    
    intervalCell.valueChangedFunction = NotificationsViewController.tableCellValueAffectNotificationsDidChange
  
    let soundCell = createRightDetailTableCell(
      title: soundTitle,
      settingsItem: Settings.notificationsSound,
      accessoryType: UITableViewCellAccessoryType.DisclosureIndicator,
      activationChangedFunction: { [unowned self] in self.soundTableCellDidActivate($0, active: $1) },
      stringFromValueFunction: NotificationsViewController.stringFromSoundFileName)
    
    soundCell.valueChangedFunction = NotificationsViewController.tableCellValueAffectNotificationsDidChange
    
    soundObserverIdentifier = Settings.notificationsSound.addObserver { value in
      soundCell.readFromExternalStorage()
    }
    
    let mainSection = TableCellsSection()
    mainSection.tableCells = [
      enableNotificationsCell,
      fromCell,
      toCell,
      intervalCell,
      soundCell]
    
    // Smart Notifications section
    
    let smartNotificationsCell = createSwitchTableCell(
      title: smartNotificationsTitle,
      settingsItem: Settings.notificationsSmart)
    
    let smartNotificationsSection = TableCellsSection()
    smartNotificationsSection.footerTitle = smartNotificationsSectionFooter
    smartNotificationsSection.tableCells = [smartNotificationsCell]
    
    // Limit Notifications section
    
    let limitNotificationsCell = createSwitchTableCell(
      title: limitNotificationsTitle,
      settingsItem: Settings.notificationsCheckWaterGoalReaching)
    
    let limitNotificationsSection = TableCellsSection()
    limitNotificationsSection.footerTitle = limitNotificationsSectionFooter
    limitNotificationsSection.tableCells = [limitNotificationsCell]

    return [mainSection, smartNotificationsSection, limitNotificationsSection]
  }
  
  private class func stringFromTimeInterval(timeInterval: NSTimeInterval) -> String {
    let overallSeconds = Int(timeInterval)
    let minutes = (overallSeconds / 60) % 60
    let hours = (overallSeconds / 3600)
    let template = NSLocalizedString("NVC:%u hr %u min", value: "%u hr %u min", comment: "NotificationsViewController: Template string for time interval")
    return String.localizedStringWithFormat(template, hours, minutes)
  }
  
  private class func timeStringFromDate(date: NSDate) -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.timeStyle = .ShortStyle
    dateFormatter.dateStyle = .NoStyle
    return dateFormatter.stringFromDate(date)
  }
  
  private class func stringFromSoundFileName(filename: String) -> String {
    return filename.stringByDeletingPathExtension.capitalizedString
  }
  
  private func soundTableCellDidActivate(tableCell: TableCell, active: Bool) {
    if active {
      performSegueWithIdentifier(Constants.chooseSoundSegue, sender: tableCell)
    }
  }

  private class func tableCellValueAffectNotificationsDidChange(tableCell: TableCell) {
    recreateNotifications()
  }

  class func recreateNotifications() {
    NotificationsHelper.removeAllNotifications()

    if Settings.notificationsEnabled.value {
      if NotificationsHelper.areLocalNotificationsRegistered() {
        NotificationsHelper.scheduleNotificationsFromSettingsForDate(NSDate())
      } else {
        NotificationsHelper.registerApplicationForLocalNotifications()
      }
    }
  }
  
}
