//
//  NotificationsHelper.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 24.12.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import UIKit

class NotificationsHelper {
  
  fileprivate struct Strings {
    // TODO: Rewrite texts
    static let notificationAlertBody = NSLocalizedString("NH:It's time to drink water!", value: "It's time to drink water!", comment: "NotificationsHelper: Text for alert body of notifications")
    static let notificationAlertAction = NSLocalizedString("NH:Drink", value: "Drink", comment: "NotificationsHelper: Text for alert action of notifications")
  }
  
  class func areLocalNotificationsRegistered() -> Bool {
    if #available(iOS 8.0, *) {
      if let notificationPermissions = UIApplication.shared.currentUserNotificationSettings {
        return notificationPermissions.types.contains(.sound) ||
               notificationPermissions.types.contains(.alert) ||
               notificationPermissions.types.contains(.badge)
      }
    }
    
    return true
  }
  
  class func registerApplicationForLocalNotifications() {
    if #available(iOS 8.0, *) {
      let notificationTypes: UIUserNotificationType = [.sound, .alert, .badge]
      let notificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
      UIApplication.shared.registerUserNotificationSettings(notificationSettings)
    }
  }
  
  class func setApplicationIconBadgeNumber(_ number: Int) {
    if #available(iOS 8.0, *) {
      if let notificationPermissions = UIApplication.shared.currentUserNotificationSettings
        , notificationPermissions.types.contains(.badge)
      {
        UIApplication.shared.applicationIconBadgeNumber = number
      }
    } else {
      UIApplication.shared.applicationIconBadgeNumber = number
    }
  }
  
  class func removeAllNotifications() {
    UIApplication.shared.cancelAllLocalNotifications()
  }

  class func scheduleNotificationsFromSettingsForDate(_ date: Date) {
    let fromTime = Settings.sharedInstance.notificationsFrom.value
    let toTime = Settings.sharedInstance.notificationsTo.value
    let interval = Settings.sharedInstance.notificationsInterval.value
    
    let fromDate = DateHelper.dateByJoiningDateTime(datePart: date, timePart: fromTime)
    let toDate = DateHelper.dateByJoiningDateTime(datePart: date, timePart: toTime)
    
    var fireDate = fromDate
    
    while !fireDate.isLaterThan(toDate) {
      scheduleNotification(fireDate: fireDate, repeatInterval: .day)
      fireDate = fireDate.addingTimeInterval(interval)
    }
  }
  
  class func rescheduleNotificationsBecauseOfIntake(intakeDate: Date) {
    removeAllNotifications()
    
    // Schedule all notifications from the next day
    let nextDayDate = DateHelper.nextDayFrom(intakeDate)
    scheduleNotificationsFromSettingsForDate(nextDayDate)
    
    // Schedule one-time notifications from time of the intake
    let toTime = Settings.sharedInstance.notificationsTo.value
    let toDate = DateHelper.dateByJoiningDateTime(datePart: intakeDate, timePart: toTime)
    let interval = Settings.sharedInstance.notificationsInterval.value
    
    var fireDate = intakeDate.addingTimeInterval(interval)
    
    while !fireDate.isLaterThan(toDate) {
      scheduleNotification(fireDate: fireDate, repeatInterval: nil)
      fireDate = fireDate.addingTimeInterval(interval)
    }
  }

  class func scheduleNotification(fireDate: Date, repeatInterval: NSCalendar.Unit?) {
    let notification = UILocalNotification()
    notification.fireDate = fireDate
    notification.alertBody = Strings.notificationAlertBody
    notification.hasAction = true
    notification.alertAction = Strings.notificationAlertAction
    notification.timeZone = TimeZone.current
    notification.soundName = Settings.sharedInstance.notificationsSound.value
    notification.applicationIconBadgeNumber = 1

    if let repeatInterval = repeatInterval {
      notification.repeatInterval = repeatInterval
    }
    
    UIApplication.shared.scheduleLocalNotification(notification)
  }

}
