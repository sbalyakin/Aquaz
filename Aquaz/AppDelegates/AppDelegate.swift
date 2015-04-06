//
//  AppDelegate.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 30.09.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit
import CoreData
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  private struct Constants {
    static let mainStoryboard = "Main"
    static let welcomeStoryboard = "Welcome"
    static let defaultRootViewController = "Root View Controller"
    static let welcomeViewController = "Welcome Wizard"
  }
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.
    Fabric.with([Crashlytics()])
    
    Localytics.integrate(GlobalConstants.localyticsApplicationKey)
    
    Logger.setup(logLevel: .Warning, assertLevel: .Error, showLogLevel: false, showFileNames: true, showLineNumbers: true)
    
    UIHelper.applyStylization()
    NotificationsHelper.setApplicationIconBadgeNumber(0)
    
    if Settings.generalHasLaunchedOnce.value == false {
      prePopulateCoreData()
      adjustNotifications()
      showWelcomeWizard()
      Settings.generalHasLaunchedOnce.value = true
    } else {
      if let options = launchOptions {
        if let notification = options[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
          showDayViewControllerForToday()
        }
      }
    }
    
    return true
  }
  
  func showDefaultRootViewControllerWithAnimation() {
    let storyboard = UIStoryboard(name: Constants.mainStoryboard, bundle: nil)
    let rootViewController: UIViewController = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: Constants.defaultRootViewController)!

    let snapShot = window!.snapshotViewAfterScreenUpdates(true)
    
    rootViewController.view.addSubview(snapShot)
    
    window!.rootViewController = rootViewController;
    
    UIView.animateWithDuration(0.65, animations: {
      snapShot.layer.opacity = 0
      snapShot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
      }, completion: { (finished) -> Void in
        snapShot.removeFromSuperview()
    })

  }
  
  private func showWelcomeWizard() {
    let storyboard = UIStoryboard(name: Constants.welcomeStoryboard, bundle: nil)
    if let welcomeWizard: UIViewController = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: Constants.welcomeViewController) {
      window?.rootViewController = welcomeWizard
    }
  }
  
  private func prePopulateCoreData() {
    // Pre populate core data if the application is running for the first time
    if let versionIdentifier = CoreDataProvider.sharedInstance.managedObjectModel.versionIdentifiers.first as? String {
      if let managedObjectContext = CoreDataProvider.sharedInstance.managedObjectContext {
        CoreDataPrePopulation.prePopulateCoreData(modelVersion: .Version1_0, managedObjectContext: managedObjectContext)
      } else {
        Logger.logSevere("Managed object context is not initialized")
      }
    } else {
      Logger.logSevere("Version identifier for managed object model is not specified")
    }
  }
  
  private func adjustNotifications() {
    if !Settings.notificationsEnabled.value {
      NotificationsHelper.removeAllNotifications()
    }
  }
  
  func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
    NotificationsHelper.setApplicationIconBadgeNumber(0)
    
    if application.applicationState == .Active {
      return
    }

    showDayViewControllerForToday()
  }
  
  func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
    NotificationsHelper.setApplicationIconBadgeNumber(0)
    showDayViewControllerForToday()
  }
  
  func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
    NotificationsHelper.removeAllNotifications()
    NotificationsHelper.scheduleNotificationsFromSettingsForDate(NSDate())
  }
  
  private func showDayViewControllerForToday() {
    if let rootViewController = window?.rootViewController as? SWRevealViewController {
      if let dayViewController = rootViewController.frontViewController.contentViewController() as? DayViewController {
        dayViewController.refreshCurrentDay(showAlert: false)
        dayViewController.switchToSelectDrinkPage()
      } else {
        rootViewController.performSegueWithIdentifier(SWSegueFrontIdentifier, sender: rootViewController)
      }
    }
  }
  
  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    Localytics.closeSession()
    Localytics.upload()
  }
  
  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    Localytics.closeSession()
    Localytics.upload()
  }
  
  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    Localytics.openSession()
    Localytics.upload()
    
    NotificationsHelper.setApplicationIconBadgeNumber(0)
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    Localytics.openSession()
    Localytics.upload()
    
    // TODO: Just for getting sqlite DB folder
    //let appFolder = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    //println("App dir: \(appFolder[0])");
    NotificationsHelper.setApplicationIconBadgeNumber(0)

    refreshCurrentDayForDayViewController(showAlert: false)
  }
  
  func applicationSignificantTimeChange(application: UIApplication) {
    let showAlert = application.applicationState == .Active
    refreshCurrentDayForDayViewController(showAlert: showAlert)
  }
  
  private func refreshCurrentDayForDayViewController(#showAlert: Bool) {
    if let rootViewController = window?.rootViewController as? SWRevealViewController {
      if let frontNavigationController = rootViewController.frontViewController as? UINavigationController {
        if let dayViewController = frontNavigationController.topViewController as? DayViewController {
          dayViewController.refreshCurrentDay(showAlert: showAlert)
        }
      }
    }
  }
  
  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    Localytics.closeSession()
    Localytics.upload()
    
    CoreDataProvider.sharedInstance.saveContext()
  }
  
}

