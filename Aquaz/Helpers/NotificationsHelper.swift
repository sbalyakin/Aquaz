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
  
  private struct Strings {
    // TODO: Rewrite texts
    static let notificationAlertBody = NSLocalizedString("NH:It's time to drink water!", value: "It's time to drink water!", comment: "NotificationsHelper: Text for alert body of notifications")
    static let notificationAlertAction = NSLocalizedString("NH:Drink", value: "Drink", comment: "NotificationsHelper: Text for alert action of notifications")
  }
  
  class func areLocalNotificationsRegistered() -> Bool {
    if #available(iOS 8.0, *) {
      if let notificationPermissions = UIApplication.sharedApplication().currentUserNotificationSettings() {
        return notificationPermissions.types.contains(.Sound) ||
               notificationPermissions.types.contains(.Alert) ||
               notificationPermissions.types.contains(.Badge)
      }
    }
    
    return true
  }
  
  class func registerApplicationForLocalNotifications() {
    if #available(iOS 8.0, *) {
      let notificationTypes: UIUserNotificationType = [.Sound, .Alert, .Badge]
      let notificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
      UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
    }
  }
  
  class func setApplicationIconBadgeNumber(number: Int) {
    if #available(iOS 8.0, *) {
      if let notificationPermissions = UIApplication.sharedApplication().currentUserNotificationSettings()
        where notificationPermissions.types.contains(.Badge)
      {
        UIApplication.sharedApplication().applicationIconBadgeNumber = number
      }
    } else {
      UIApplication.sharedApplication().applicationIconBadgeNumber = number
    }
  }
  
  class func removeAllNotifications() {
    UIApplication.sharedApplication().cancelAllLocalNotifications()
  }

  class func scheduleNotificationsFromSettingsForDate(date: NSDate) {
    let fromTime = Settings.sharedInstance.notificationsFrom.value
    let toTime = Settings.sharedInstance.notificationsTo.value
    let interval = Settings.sharedInstance.notificationsInterval.value
    
    let fromDate = DateHelper.dateByJoiningDateTime(datePart: date, timePart: fromTime)
    let toDate = DateHelper.dateByJoiningDateTime(datePart: date, timePart: toTime)
    
    var fireDate = fromDate
    
    while !fireDate.isLaterThan(toDate) {
      scheduleNotification(fireDate: fireDate, repeatInterval: .Day)
      fireDate = fireDate.dateByAddingTimeInterval(interval)
    }
  }
  
  class func rescheduleNotificationsBecauseOfIntake(intakeDate intakeDate: NSDate) {
    removeAllNotifications()
    
    // Schedule all notifications from the next day
    let nextDayDate = DateHelper.addToDate(intakeDate, years: 0, months: 0, days: 1)
    scheduleNotificationsFromSettingsForDate(nextDayDate)
    
    // Schedule one-time notifications from time of the intake
    let toTime = Settings.sharedInstance.notificationsTo.value
    let toDate = DateHelper.dateByJoiningDateTime(datePart: intakeDate, timePart: toTime)
    let interval = Settings.sharedInstance.notificationsInterval.value
    
    var fireDate = intakeDate.dateByAddingTimeInterval(interval)
    
    while !fireDate.isLaterThan(toDate) {
      scheduleNotification(fireDate: fireDate, repeatInterval: nil)
      fireDate = fireDate.dateByAddingTimeInterval(interval)
    }
  }

  class func scheduleNotification(fireDate fireDate: NSDate, repeatInterval: NSCalendarUnit?) {
    let notification = UILocalNotification()
    notification.fireDate = fireDate
    notification.alertBody = Strings.notificationAlertBody
    notification.hasAction = true
    notification.alertAction = Strings.notificationAlertAction
    notification.timeZone = NSTimeZone.defaultTimeZone()
    notification.soundName = Settings.sharedInstance.notificationsSound.value
    notification.applicationIconBadgeNumber = 1

    if let repeatInterval = repeatInterval {
      notification.repeatInterval = repeatInterval
    }
    
    UIApplication.sharedApplication().scheduleLocalNotification(notification)
  }

}