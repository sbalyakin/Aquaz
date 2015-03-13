//
//  NotificationsHelper.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 24.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import UIKit

class NotificationsHelper {
  
  private struct Strings {
    // TODO: Rewrite texts
    static let notificationAlertBody = NSLocalizedString("NH:It is time to drink!", value: "It is time to drink!", comment: "NotificationsHelper: Text for alert body of notifications")
    static let notificationAlertAction = NSLocalizedString("NH:Drink", value: "Drink", comment: "NotificationsHelper: Text for alert action of notifications")
  }
  
  class func areLocalNotificationsRegistered() -> Bool {
    if UIApplication.instancesRespondToSelector(Selector("currentUserNotificationSettings")) {
      let notificationPermissions = UIApplication.sharedApplication().currentUserNotificationSettings()
      if notificationPermissions.types & UIUserNotificationType.Sound == .Sound ||
         notificationPermissions.types & UIUserNotificationType.Alert == .Alert ||
         notificationPermissions.types & UIUserNotificationType.Badge == .Badge {
        return true
      }
      
      return false
    }
    
    return true
  }
  
  class func registerApplicationForLocalNotifications() {
    if UIApplication.instancesRespondToSelector(Selector("registerUserNotificationSettings:"))
    {
      let notificationTypes: UIUserNotificationType = .Sound | .Alert | .Badge
      let notificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
      UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
    }
  }
  
  class func setApplicationIconBadgeNumber(number: Int) {
    if UIApplication.instancesRespondToSelector(Selector("currentUserNotificationSettings")) {
      let notificationPermissions = UIApplication.sharedApplication().currentUserNotificationSettings()
      if notificationPermissions.types & UIUserNotificationType.Badge == .Badge {
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
    
    for var fireDate = fromDate; !fireDate.isLaterThan(toDate); fireDate = fireDate.dateByAddingTimeInterval(interval) {
      scheduleNotification(fireDate: fireDate, repeatInterval: .CalendarUnitDay)
    }
  }
  
  class func rescheduleNotificationsBecauseOfIntake(#intakeDate: NSDate) {
    removeAllNotifications()
    
    // Schedule all notifications from the next day
    let nextDayDate = DateHelper.addToDate(intakeDate, years: 0, months: 0, days: 1)
    scheduleNotificationsFromSettingsForDate(nextDayDate)
    
    // Schedule one-time notifications from time of the intake
    let toTime = Settings.sharedInstance.notificationsTo.value
    let toDate = DateHelper.dateByJoiningDateTime(datePart: intakeDate, timePart: toTime)
    let interval = Settings.sharedInstance.notificationsInterval.value
    
    for var fireDate = intakeDate; !fireDate.isLaterThan(toDate); fireDate = fireDate.dateByAddingTimeInterval(interval) {
      scheduleNotification(fireDate: fireDate, repeatInterval: nil)
    }
  }

  class func scheduleNotification(#fireDate: NSDate, repeatInterval: NSCalendarUnit?) {
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