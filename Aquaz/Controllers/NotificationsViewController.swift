//
//  NotificationsViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 08.12.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

extension String: CustomStringConvertible {
  public var description: String {
    return self
  }
}

class NotificationsViewController: OmegaSettingsViewController {
  
  private var notificationSoundObserver: SettingsObserver?
  
  private struct Constants {
    static let chooseSoundSegue = "Choose Sound"
  }
  
  private struct LocalizedStrings {
    
    lazy var smartNotificationsBannerText: String = NSLocalizedString("SVC:Smart Notifications mode is available in the full version only.",
      value: "Smart Notifications mode are available in the full version only.",
      comment: "StatisticsViewController: Text for banner shown to promote the full version of Aquaz if user tries to activate Smart notifications mode")

    lazy var limitNotificationsBannerText: String = NSLocalizedString("SVC:Limit Notifications mode is available in the full version only.",
      value: "Limit Notifications mode is available in the full version only.",
      comment: "StatisticsViewController: Text for banner shown to promote the full version of Aquaz if user tries to activate Limit notifications mode")

    lazy var enableNotificationsTitle: String = NSLocalizedString("NVC:Enable Notifications", value: "Enable Notifications",
      comment: "NotificationsViewController: Title for [Enable Notification] setting")
    
    lazy var fromTitle: String = NSLocalizedString("NVC:From", value: "From",
      comment: "NotificationsViewController: Title for [From] setting")
    
    lazy var toTitle: String = NSLocalizedString("NVC:To", value: "To",
      comment: "NotificationsViewController: Title for [To] setting")
    
    lazy var intervalTitle: String = NSLocalizedString("NVC:Interval", value: "Interval",
      comment: "NotificationsViewController: Title for [Interval] setting")
    
    lazy var intervalHourTitle: String = NSLocalizedString("NVC:hr", value: "hr",
      comment: "NotificationsViewController: contraction for hour")
    
    lazy var intervalMinuteTitle: String = NSLocalizedString("NVC:min", value: "min",
      comment: "NotificationsViewController: contraction for minute")
    
    lazy var soundTitle: String = NSLocalizedString("NVC:Notification Sound", value: "Notification Sound",
      comment: "NotificationsViewController: Title for [Notification Sound] setting")
    
    lazy var smartNotificationsTitle: String = NSLocalizedString("NVC:Smart Notifications", value: "Smart Notifications",
      comment: "NotificationsViewController: Title for [Smart Notifications] setting")
    
    lazy var limitNotificationsTitle: String = NSLocalizedString("NVC:Limit Notifications", value: "Limit Notifications",
      comment: "NotificationsViewController: Title for [Limit Notifications] setting")
    
    lazy var smartNotificationsSectionFooter: String = NSLocalizedString(
      "NVC:Enable snooze notifications taking into account time of drink intake.",
      value: "Enable snooze notifications taking into account time of drink intake.",
      comment: "NotificationsViewController: Footer text for [Smart Notifications] section")
    
    lazy var limitNotificationsSectionFooter: String = NSLocalizedString("NVC:When enabled, notifications will not be shown if you have already drunk your daily water intake.",
      value: "When enabled, notifications will not be shown if you have already drunk your daily water intake.",
      comment: "NotificationsViewController: Footer text for [Limit Notifications] section")

  }
  
  private var localizedStrings = LocalizedStrings()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    UIHelper.applyStyleToViewController(self)
    rightDetailValueColor = StyleKit.settingsTablesValueColor
    rightDetailSelectedValueColor = StyleKit.settingsTablesSelectedValueColor
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  override func createTableCellsSections() -> [TableCellsSection] {
    // General section
    
    let enableNotificationsCell = createSwitchTableCell(
      title: localizedStrings.enableNotificationsTitle,
      settingsItem: Settings.sharedInstance.notificationsEnabled)
    
    enableNotificationsCell.valueChangedFunction = NotificationsViewController.tableCellValueAffectNotificationsDidChange
    
    let fromCell = createDateRightDetailTableCell(
      title: localizedStrings.fromTitle,
      settingsItem: Settings.sharedInstance.notificationsFrom,
      datePickerMode: .Time,
      minimumDate: nil,
      maximumDate: nil,
      height: .Large,
      stringFromValueFunction: NotificationsViewController.timeStringFromDate)
    
    fromCell.valueChangedFunction = NotificationsViewController.tableCellValueAffectNotificationsDidChange

    let toCell = createDateRightDetailTableCell(
      title: localizedStrings.toTitle,
      settingsItem: Settings.sharedInstance.notificationsTo,
      datePickerMode: .Time,
      minimumDate: nil,
      maximumDate: nil,
      height: .Large,
      stringFromValueFunction: NotificationsViewController.timeStringFromDate)
    
    toCell.valueChangedFunction = NotificationsViewController.tableCellValueAffectNotificationsDidChange
    
    let timeComponents = [
      TimeIntervalPickerTableCellComponent(
        calendarUnit: NSCalendarUnit.Hour,
        minValue: 1, maxValue: 6, step: 1, title: localizedStrings.intervalHourTitle, width: 100),
      TimeIntervalPickerTableCellComponent(
        calendarUnit: NSCalendarUnit.Minute,
        minValue: 0, maxValue: 59, step: 5, title: localizedStrings.intervalMinuteTitle, width: 100)]
    
    let intervalCell = createTimeIntervalRightDetailTableCell(
      title: localizedStrings.intervalTitle,
      settingsItem: Settings.sharedInstance.notificationsInterval,
      timeComponents: timeComponents,
      height: .Large,
      stringFromValueFunction: NotificationsViewController.stringFromTimeInterval)
    
    intervalCell.valueChangedFunction = NotificationsViewController.tableCellValueAffectNotificationsDidChange
  
    let soundCell = createRightDetailTableCell(
      title: localizedStrings.soundTitle,
      settingsItem: Settings.sharedInstance.notificationsSound,
      accessoryType: UITableViewCellAccessoryType.DisclosureIndicator,
      activationChangedFunction: { [weak self] in self?.soundTableCellDidActivate($0, active: $1) },
      stringFromValueFunction: NotificationsViewController.stringFromSoundFileName)
    
    soundCell.valueChangedFunction = NotificationsViewController.tableCellValueAffectNotificationsDidChange
    
    notificationSoundObserver = Settings.sharedInstance.notificationsSound.addObserver { _ in
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
      title: localizedStrings.smartNotificationsTitle,
      settingsItem: Settings.sharedInstance.notificationsSmart)
    
    let smartNotificationsSection = TableCellsSection()
    smartNotificationsSection.footerTitle = localizedStrings.smartNotificationsSectionFooter
    smartNotificationsSection.tableCells = [smartNotificationsCell]
    
    // Limit Notifications section
    
    let limitNotificationsCell = createSwitchTableCell(
      title: localizedStrings.limitNotificationsTitle,
      settingsItem: Settings.sharedInstance.notificationsLimit)

    let limitNotificationsSection = TableCellsSection()
    limitNotificationsSection.footerTitle = localizedStrings.limitNotificationsSectionFooter
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
    for sound in NotificationSounds.soundList {
      if sound.fileName == filename {
        return sound.title
      }
    }
    
    let url = NSURL(fileURLWithPath: filename)
    return url.URLByDeletingPathExtension?.lastPathComponent?.capitalizedString ?? filename.capitalizedString
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

    if Settings.sharedInstance.notificationsEnabled.value {
      if NotificationsHelper.areLocalNotificationsRegistered() {
        NotificationsHelper.scheduleNotificationsFromSettingsForDate(NSDate())
      } else {
        NotificationsHelper.registerApplicationForLocalNotifications()
      }
    }
  }
  
}
