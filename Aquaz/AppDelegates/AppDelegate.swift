//
//  AppDelegate.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 30.09.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
//

import UIKit
import CoreData
import Fabric
import Crashlytics
import Appodeal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  private var wormholeDataProvider: WormholeDataProvider!
  
  private struct Constants {
    static let defaultRootViewController = "Root View Controller"
    static let welcomeViewController = "Welcome Wizard"
  }
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    Fabric.with([Crashlytics()])
    
    #if DEBUG
      Logger.setup(logLevel: .Warning, assertLevel: .Error, consoleLevel: .Debug, showLogLevel: false, showFileNames: true, showLineNumbers: true, showFunctionNames: true)
    #else
      Logger.setup(logLevel: .Warning, assertLevel: .None, consoleLevel: .None, showLogLevel: false, showFileNames: true, showLineNumbers: true, showFunctionNames: true)
    #endif

    UIHelper.applyStylization()
    NotificationsHelper.setApplicationIconBadgeNumber(0)
    
    // Initialize the core data stack
    CoreDataStack.sharedInstance
    
    #if DEBUG
      let isSnapshotMode = NSProcessInfo.processInfo().arguments.contains("-SNAPSHOT")
      
      if isSnapshotMode {
        if #available(iOS 9.0, *) {
          SnapshotsInitializer.prepareUserData()
        }
      } else {
        initialSetup(launchOptions: launchOptions)
      }
    #else
      initialSetup(launchOptions: launchOptions)
    #endif
    
    wormholeDataProvider = WormholeDataProvider()
    
    setupSynchronizationWithCoreData()

    if #available(iOS 9.0, *) {
      setupHealthKitSynchronization()
      
      // Just for creating an instance of the connectivity provider
      ConnectivityProvider.sharedInstance
    }

    return true
  }

  private func initialSetup(launchOptions launchOptions: [NSObject: AnyObject]?) {
    // General case
    if !Settings.sharedInstance.generalFullVersion.value {
      Appodeal.initializeWithApiKey(GlobalConstants.appodealApiKey, types: AppodealAdType.Interstitial)
      
      // Just for creating shared instance of in-app purchase manager and to start observing transaction states
      InAppPurchaseManager.sharedInstance
    }
    
    if Settings.sharedInstance.generalHasLaunchedOnce.value == false {
      prePopulateCoreData()
      removeDisabledNotifications()
      showWelcomeWizard()
      Settings.sharedInstance.generalHasLaunchedOnce.value = true
    } else {
      if let options = launchOptions {
        if let _ = options[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
          showDayViewControllerForToday()
        }
      }
    }
  }
    
  private func setupSynchronizationWithCoreData() {
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "updateNotifications:",
      name: NSManagedObjectContextDidSaveNotification,
      object: nil)
  }

  @available(iOS 9.0, *)
  private func setupHealthKitSynchronization() {
    CoreDataStack.inPrivateContext { privateContext in
      HealthKitProvider.sharedInstance.initSynchronizationForManagedObjectContext(privateContext)
    }
  }

  func updateNotifications(notification: NSNotification) {
    if !Settings.sharedInstance.notificationsEnabled.value {
      return
    }

    if !Settings.sharedInstance.notificationsLimit.value && !Settings.sharedInstance.notificationsSmart.value {
      return
    }

    if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> {
      // Searching for the last inserted intake by date
      var lastIntakeDate: NSDate?
      
      for insertedObject in insertedObjects {
        if let intake = insertedObject as? Intake {
          if lastIntakeDate == nil || intake.date.isLaterThan(lastIntakeDate!) {
            lastIntakeDate = intake.date
          }
        }
      }
      
      if let lastIntakeDate = lastIntakeDate where DateHelper.areDatesEqualByDays(lastIntakeDate, NSDate()) {
        if Settings.sharedInstance.notificationsLimit.value {
          CoreDataStack.inPrivateContext { privateContext in
            let beginDate = NSDate()
            let endDate = DateHelper.addToDate(beginDate, years: 0, months: 0, days: 1)
            
            let todayAmountParts = Intake.fetchIntakeAmountPartsGroupedBy(.Day, beginDate: beginDate, endDate: endDate, dayOffsetInHours: 0,  aggregateFunction: .Summary, managedObjectContext: privateContext).first!
            
            let todayWaterGoal = WaterGoal.fetchWaterGoalAmounts(beginDate: beginDate, endDate: endDate, managedObjectContext: privateContext).first!
            
            if todayAmountParts.hydration >= (todayWaterGoal + todayAmountParts.dehydration) {
              dispatch_async(dispatch_get_main_queue()) {
                NotificationsHelper.removeAllNotifications()
                let nextDayDate = DateHelper.addToDate(lastIntakeDate, years: 0, months: 0, days: 1)
                NotificationsHelper.scheduleNotificationsFromSettingsForDate(nextDayDate)
              }
            } else if Settings.sharedInstance.notificationsSmart.value {
              dispatch_async(dispatch_get_main_queue()) {
                NotificationsHelper.rescheduleNotificationsBecauseOfIntake(intakeDate: lastIntakeDate)
              }
            }
          }
        } else if Settings.sharedInstance.notificationsSmart.value {
          NotificationsHelper.rescheduleNotificationsBecauseOfIntake(intakeDate: lastIntakeDate)
        }
      }
    }
  }
  
  func showDefaultRootViewControllerWithAnimation() {
    let storyboard = UIStoryboard(name: GlobalConstants.storyboardMain, bundle: nil)
    let rootViewController: UIViewController = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: Constants.defaultRootViewController)!

    let snapShot = window!.snapshotViewAfterScreenUpdates(true)
    
    rootViewController.view.addSubview(snapShot)
    
    window!.rootViewController = rootViewController;
    
    UIView.animateWithDuration(0.65, animations: {
      snapShot.layer.opacity = 0
      snapShot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
    }, completion: { _ in
        snapShot.removeFromSuperview()
    })
  }
  
  private func showWelcomeWizard() {
    let storyboard = UIStoryboard(name: GlobalConstants.storyboardWelcome, bundle: nil)
    if let welcomeWizard: UIViewController = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: Constants.welcomeViewController) {
      window?.rootViewController = welcomeWizard
    }
  }
  
  private func prePopulateCoreData() {
    CoreDataStack.inPrivateContext { privateContext in
      if !CoreDataPrePopulation.isCoreDataPrePopulated(managedObjectContext: privateContext) {
        CoreDataPrePopulation.prePopulateCoreData(managedObjectContext: privateContext, saveContext: true)
      }
    }
  }
  
  private func removeDisabledNotifications() {
    if !Settings.sharedInstance.notificationsEnabled.value {
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
  
  @available(iOS 8.0, *)
  func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
    NotificationsHelper.removeAllNotifications()
    NotificationsHelper.scheduleNotificationsFromSettingsForDate(NSDate())
  }
  
  private func showDayViewControllerForToday() {
    if let tabBarController = window?.rootViewController as? UITabBarController,
       let viewControllers = tabBarController.viewControllers
    {
      for (index, viewController) in viewControllers.enumerate() {
        if let dayViewController = viewController.contentViewController as? DayViewController where dayViewController.mode == .General {
          dayViewController.refreshCurrentDay(showAlert: false)
          dayViewController.switchToSelectDrinkPage()
          tabBarController.selectedIndex = index
        }
      }
    }
  }
  
  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NotificationsHelper.setApplicationIconBadgeNumber(0)
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // Just for getting sqlite DB folder
    //let appFolder = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    //println("App dir: \(appFolder[0])");

    NotificationsHelper.setApplicationIconBadgeNumber(0)

    refreshCurrentDayForDayViewController(showAlert: false)
  }
  
  func applicationSignificantTimeChange(application: UIApplication) {
    let showAlert = application.applicationState == .Active
    refreshCurrentDayForDayViewController(showAlert: showAlert)
  }
  
  private func refreshCurrentDayForDayViewController(showAlert showAlert: Bool) {
    if let tabBarController = window?.rootViewController as? UITabBarController,
       let viewControllers = tabBarController.viewControllers
    {
      for viewController in viewControllers {
        if let dayViewController = viewController.contentViewController as? DayViewController {
          dayViewController.refreshCurrentDay(showAlert: showAlert)
        }
      }
    }
  }
  
  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    CoreDataStack.saveAllContexts()
    
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
}

