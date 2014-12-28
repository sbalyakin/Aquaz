//
//  NotificationsHelper.swift
//  Water Me
//
//  Created by Sergey Balyakin on 24.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation

class NotificationsHelper {
  
  private struct Strings {
    // TODO: Rewrite texts
    static let notificationAlertBody = NSLocalizedString("NH:It's time to drink!", value: "It's time to drink!", comment: "NotificationsHelper: Text for alert body of notifications")
    static let notificationAlertAction = NSLocalizedString("NH:Water me", value: "Water me", comment: "NotificationsHelper: Text for alert action of notifications")
  }
  
  class func registerApplicationForLocalNotifications() {
    if UIApplication.instancesRespondToSelector(Selector("registerUserNotificationSettings:"))
    {
      let notificationTypes: UIUserNotificationType = .Sound | .Alert | .Badge
      let notificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
      UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
    }
  }
  
  class func removeAllNotifications() {
    UIApplication.sharedApplication().cancelAllLocalNotifications()
  }

  class func addNotificationsFromSettingsForDate(date: NSDate) {
    let fromTime = Settings.sharedInstance.notificationsFrom.value
    let toTime = Settings.sharedInstance.notificationsTo.value
    let interval = Settings.sharedInstance.notificationsInterval.value
    
    let fromDate = DateHelper.dateByJoiningDateTime(datePart: date, timePart: fromTime)
    let toDate = DateHelper.dateByJoiningDateTime(datePart: date, timePart: toTime)
    
    for var fireDate = fromDate; !fireDate.isLaterThan(toDate); fireDate = fireDate.dateByAddingTimeInterval(interval) {
      addNotification(fireDate: fireDate, repeatInterval: .CalendarUnitDay)
    }
  }
  
  class func rescheduleNotificationsBecauseOfConsumption(#consumptionDate: NSDate) {
    removeAllNotifications()
    
    // Schedule all notifications from the next day
    let nextDayDate = DateHelper.addToDate(consumptionDate, years: 0, months: 0, days: 1)
    addNotificationsFromSettingsForDate(nextDayDate)
    
    // Schedule one-time notifications from the consumption time
    let toTime = Settings.sharedInstance.notificationsTo.value
    let toDate = DateHelper.dateByJoiningDateTime(datePart: consumptionDate, timePart: toTime)
    let interval = Settings.sharedInstance.notificationsInterval.value
    
    for var fireDate = consumptionDate; !fireDate.isLaterThan(toDate); fireDate = fireDate.dateByAddingTimeInterval(interval) {
      addNotification(fireDate: fireDate, repeatInterval: nil)
    }
  }

  class func addNotification(#fireDate: NSDate, repeatInterval: NSCalendarUnit?) {
    let notification = UILocalNotification()
    notification.fireDate = fireDate
    notification.alertBody = Strings.notificationAlertBody
    notification.hasAction = true
    notification.alertAction = Strings.notificationAlertAction
    notification.timeZone = NSTimeZone.defaultTimeZone()

    if let interval = repeatInterval {
      notification.repeatInterval = interval
    }
    
    UIApplication.sharedApplication().scheduleLocalNotification(notification)
  }

}