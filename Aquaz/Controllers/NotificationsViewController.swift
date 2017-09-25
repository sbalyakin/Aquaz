//
//  NotificationsViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 08.12.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class NotificationsViewController: OmegaSettingsViewController {
  
  fileprivate var notificationSoundObserver: SettingsObserver?
  
  #if AQUAZLITE
  private var fullVersionBannerView: InfoBannerView?
  #endif
  
  fileprivate struct Constants {
    static let chooseSoundSegue = "Choose Sound"
    #if AQUAZLITE
    static let fullVersionViewControllerIdentifier = "FullVersionViewController"
    #endif
  }
  
  fileprivate struct LocalizedStrings {
    
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
      "NVC:Enable to snooze notifications taking into account time of drink intake.",
      value: "Enable to snooze notifications taking into account time of drink intake.",
      comment: "NotificationsViewController: Footer text for [Smart Notifications] section")
    
    lazy var limitNotificationsSectionFooter: String = NSLocalizedString("NVC:When enabled, notifications will not be shown if you have already drunk your daily water intake.",
      value: "When enabled, notifications will not be shown if you have already drunk your daily water intake.",
      comment: "NotificationsViewController: Footer text for [Limit Notifications] section")

  }
  
  fileprivate var localizedStrings = LocalizedStrings()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    UIHelper.applyStyleToViewController(self)
    rightDetailValueColor = StyleKit.settingsTablesValueColor
    rightDetailSelectedValueColor = StyleKit.settingsTablesSelectedValueColor
    
    #if AQUAZLITE
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(fullVersionIsPurchased(_:)),
                                           name: NSNotification.Name(rawValue: GlobalConstants.notificationFullVersionIsPurchased), object: nil)
    #endif
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
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
      datePickerMode: .time,
      stringFromValueFunction: NotificationsViewController.timeStringFromDate,
      minimumDate: nil,
      maximumDate: nil,
      height: .large)
    
    fromCell.valueChangedFunction = NotificationsViewController.tableCellValueAffectNotificationsDidChange

    let toCell = createDateRightDetailTableCell(
      title: localizedStrings.toTitle,
      settingsItem: Settings.sharedInstance.notificationsTo,
      datePickerMode: .time,
      stringFromValueFunction: NotificationsViewController.timeStringFromDate,
      minimumDate: nil,
      maximumDate: nil,
      height: .large)
    
    toCell.valueChangedFunction = NotificationsViewController.tableCellValueAffectNotificationsDidChange
    
    let timeComponents = [
      TimeIntervalPickerTableCellComponent(
        calendarComponents: .hour,
        minValue: 1, maxValue: 6, step: 1, title: localizedStrings.intervalHourTitle, width: 100),
      TimeIntervalPickerTableCellComponent(
        calendarComponents: .minute,
        minValue: 0, maxValue: 59, step: 5, title: localizedStrings.intervalMinuteTitle, width: 100)]
    
    let intervalCell = createTimeIntervalRightDetailTableCell(
      title: localizedStrings.intervalTitle,
      settingsItem: Settings.sharedInstance.notificationsInterval,
      timeComponents: timeComponents,
      stringFromValueFunction: NotificationsViewController.stringFromTimeInterval,
      height: .large)
    
    intervalCell.valueChangedFunction = NotificationsViewController.tableCellValueAffectNotificationsDidChange
  
    let soundCell = createRightDetailTableCell(
      title: localizedStrings.soundTitle,
      settingsItem: Settings.sharedInstance.notificationsSound,
      stringFromValueFunction: NotificationsViewController.stringFromSoundFileName,
      accessoryType: UITableViewCellAccessoryType.disclosureIndicator)
    
    soundCell.activationChangedFunction = { [weak self] in self?.soundTableCellDidActivate($0, active: $1) }
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
    
    #if AQUAZLITE
    smartNotificationsCell.valueChangedFunction = { [weak self] in self?.smartNotificationsValueChanged(tableCell: $0) }
    #endif
    
    let smartNotificationsSection = TableCellsSection()
    smartNotificationsSection.footerTitle = localizedStrings.smartNotificationsSectionFooter
    smartNotificationsSection.tableCells = [smartNotificationsCell]
    
    // Limit Notifications section
    
    let limitNotificationsCell = createSwitchTableCell(
      title: localizedStrings.limitNotificationsTitle,
      settingsItem: Settings.sharedInstance.notificationsLimit)

    #if AQUAZLITE
    limitNotificationsCell.valueChangedFunction = { [weak self] in self?.limitNotificationsValueChanged(tableCell: $0) }
    #endif
    
    let limitNotificationsSection = TableCellsSection()
    limitNotificationsSection.footerTitle = localizedStrings.limitNotificationsSectionFooter
    limitNotificationsSection.tableCells = [limitNotificationsCell]

    return [mainSection, smartNotificationsSection, limitNotificationsSection]
  }
  
  fileprivate class func stringFromTimeInterval(_ timeInterval: TimeInterval) -> String {
    let overallSeconds = Int(timeInterval)
    let minutes = (overallSeconds / 60) % 60
    let hours = (overallSeconds / 3600)
    let template = NSLocalizedString("NVC:%u hr %u min", value: "%u hr %u min", comment: "NotificationsViewController: Template string for time interval")
    return String.localizedStringWithFormat(template, hours, minutes)
  }
  
  fileprivate class func timeStringFromDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.timeStyle = .short
    dateFormatter.dateStyle = .none
    return dateFormatter.string(from: date)
  }
  
  #if AQUAZLITE
  private func smartNotificationsValueChanged(tableCell: TableCell) {
    if let valueCell = tableCell as? TableCellWithValue<Bool>, !Settings.sharedInstance.generalFullVersion.value && valueCell.value {
      showFullVersionBanner(text: localizedStrings.smartNotificationsBannerText)
      valueCell.value = false
    }
  }
  
  private func limitNotificationsValueChanged(tableCell: TableCell) {
    if let valueCell = tableCell as? TableCellWithValue<Bool>, !Settings.sharedInstance.generalFullVersion.value && valueCell.value {
      showFullVersionBanner(text: localizedStrings.limitNotificationsBannerText)
      valueCell.value = false
    }
  }
  
  private func showFullVersionBanner(text: String) {
    if fullVersionBannerView != nil {
      return
    }
    
    fullVersionBannerView = InfoBannerView.create()
    fullVersionBannerView!.infoLabel.text = text
    fullVersionBannerView!.infoImageView.image = ImageHelper.loadImage(.BannerFullVersion)
    fullVersionBannerView!.bannerWasTappedFunction = { [weak self] _ in self?.fullVersionBannerWasTapped() }
    fullVersionBannerView!.showAndHide(animated: true, displayTime: 3, parentView: view) { _ in
      self.fullVersionBannerView = nil
    }
  }
  
  #if AQUAZLITE
  @objc func fullVersionIsPurchased(_ notification: NSNotification) {
    hideFullVersionBanner()
  }
  #endif
  
  private func hideFullVersionBanner() {
    fullVersionBannerView?.hide(animated: true) { _ in
      self.fullVersionBannerView = nil
    }
  }
  
  func fullVersionBannerWasTapped() {
    if let fullVersionViewController: FullVersionViewController = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: Constants.fullVersionViewControllerIdentifier) {
      navigationController!.pushViewController(fullVersionViewController, animated: true)
    }
  }
  #endif
  
  fileprivate class func stringFromSoundFileName(_ filename: String) -> String {
    for sound in NotificationSounds.soundList {
      if sound.fileName == filename {
        return sound.title
      }
    }
    
    let url = URL(fileURLWithPath: filename)
    return url.deletingPathExtension().lastPathComponent.capitalized 
  }
  
  fileprivate func soundTableCellDidActivate(_ tableCell: TableCell, active: Bool) {
    if active {
      performSegue(withIdentifier: Constants.chooseSoundSegue, sender: tableCell)
    }
  }

  fileprivate class func tableCellValueAffectNotificationsDidChange(_ tableCell: TableCell) {
    recreateNotifications()
  }

  class func recreateNotifications() {
    NotificationsHelper.removeAllNotifications()

    if Settings.sharedInstance.notificationsEnabled.value {
      if NotificationsHelper.areLocalNotificationsRegistered() {
        NotificationsHelper.scheduleNotificationsFromSettingsForDate(Date())
      } else {
        NotificationsHelper.registerApplicationForLocalNotifications()
      }
    }
  }
  
}
