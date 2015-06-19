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
  private var fullVersionBannerView: InfoBannerView?
  
  private struct Constants {
    static let chooseSoundSegue = "Choose Sound"
    static let fullVersionViewControllerIdentifier = "FullVersionViewController"
  }
  
  private struct LocalizedStrings {
    
    lazy var smartNotificationsBannerText = NSLocalizedString("SVC:Smart Notifications mode is available in the full version only.",
      value: "Smart Notifications mode are available in the full version only.",
      comment: "StatisticsViewController: Text for banner shown to promote the full version of Aquaz if user tries to activate Smart notifications mode")

    lazy var limitNotificationsBannerText = NSLocalizedString("SVC:Limit Notifications mode is available in the full version only.",
      value: "Limit Notifications mode is available in the full version only.",
      comment: "StatisticsViewController: Text for banner shown to promote the full version of Aquaz if user tries to activate Limit notifications mode")

  }
  
  private var localizedStrings = LocalizedStrings()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    UIHelper.applyStyle(self)
    rightDetailValueColor = StyleKit.settingsTablesValueColor
    rightDetailSelectedValueColor = StyleKit.settingsTablesSelectedValueColor

    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "fullVersionIsPurchased:",
      name: GlobalConstants.notificationFullVersionIsPurchased, object: nil)
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)

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
      TimeIntervalPickerTableCellComponent(calendarUnit: NSCalendarUnit.CalendarUnitHour, minValue: 1, maxValue: 6, step: 1, title: intervalHourTitle, width: 100),
      TimeIntervalPickerTableCellComponent(calendarUnit: NSCalendarUnit.CalendarUnitMinute, minValue: 0, maxValue: 59, step: 5, title: intervalMinuteTitle, width: 100)]
    
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
    
    smartNotificationsCell.valueChangedFunction = { [unowned self] in self.smartNotificationsValueChanged($0) }

    let smartNotificationsSection = TableCellsSection()
    smartNotificationsSection.footerTitle = smartNotificationsSectionFooter
    smartNotificationsSection.tableCells = [smartNotificationsCell]
    
    // Limit Notifications section
    
    let limitNotificationsCell = createSwitchTableCell(
      title: limitNotificationsTitle,
      settingsItem: Settings.notificationsLimit)

    limitNotificationsCell.valueChangedFunction = { [unowned self] in self.limitNotificationsValueChanged($0) }

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
  
  private func smartNotificationsValueChanged(tableCell: TableCell) {
    if let valueCell = tableCell as? TableCellWithValue<Bool> where !Settings.generalFullVersion.value && valueCell.value {
      showFullVersionBanner(text: localizedStrings.smartNotificationsBannerText)
      valueCell.value = false
    }
  }

  private func limitNotificationsValueChanged(tableCell: TableCell) {
    if let valueCell = tableCell as? TableCellWithValue<Bool> where !Settings.generalFullVersion.value && valueCell.value {
      showFullVersionBanner(text: localizedStrings.limitNotificationsBannerText)
      valueCell.value = false
    }
  }

  private func showFullVersionBanner(#text: String) {
    if fullVersionBannerView != nil {
      return
    }
    
    fullVersionBannerView = InfoBannerView.create()
    fullVersionBannerView!.infoLabel.text = text
    fullVersionBannerView!.infoImageView.image = ImageHelper.loadImage(.BannerFullVersion)
    fullVersionBannerView!.bannerWasTappedFunction = { [unowned self] _ in self.fullVersionBannerWasTapped() }
    fullVersionBannerView!.showAndHide(animated: true, displayTime: 3, parentView: view) { finished in
      self.fullVersionBannerView = nil
    }
  }
  
  func fullVersionIsPurchased(notification: NSNotification) {
    hideFullVersionBanner()
  }

  private func hideFullVersionBanner() {
    fullVersionBannerView?.hide(animated: true)
    fullVersionBannerView = nil
  }
  
  func fullVersionBannerWasTapped() {
    if let fullVersionViewController: FullVersionViewController = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: Constants.fullVersionViewControllerIdentifier) {
      navigationController!.pushViewController(fullVersionViewController, animated: true)
    }
  }

  private class func stringFromSoundFileName(filename: String) -> String {
    for sound in NotificationSounds.soundList {
      if sound.fileName == filename {
        return sound.title
      }
    }
    
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
