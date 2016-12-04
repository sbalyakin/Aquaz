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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  fileprivate var wormholeDataProvider: WormholeDataProvider!
  
  fileprivate struct Constants {
    static let defaultRootViewController = "Root View Controller"
    static let welcomeViewController = "Welcome Wizard"
  }
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    Fabric.with([Crashlytics()])
    
    #if DEBUG
      Logger.setup(logLevel: .warning, assertLevel: .error, consoleLevel: .debug, showLogLevel: false, showFileNames: true, showLineNumbers: true, showFunctionNames: true)
    #else
      Logger.setup(logLevel: .warning, assertLevel: .none, consoleLevel: .none, showLogLevel: false, showFileNames: true, showLineNumbers: true, showFunctionNames: true)
    #endif

    UIHelper.applyStylization()
    NotificationsHelper.setApplicationIconBadgeNumber(0)
    
    // Initialize the core data stack
    _ = CoreDataStack.sharedInstance
    
    #if DEBUG && AQUAZPRO
      let isSnapshotMode = ProcessInfo.processInfo.arguments.contains("-SNAPSHOT")
      
      if isSnapshotMode {
        if #available(iOS 9.3, *) {
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

    if #available(iOS 9.3, *) {
      setupHealthKitSynchronization()
      
      // Just for creating an instance of the connectivity provider
      ConnectivityProvider.sharedInstance.startSession()
    }

    return true
  }

  fileprivate func initialSetup(launchOptions: [AnyHashable: Any]?) {
    #if AQUAZLITE
    // General case
    if !Settings.sharedInstance.generalFullVersion.value {
      // TODO: Remove for a while
      //Appodeal.initializeWithApiKey(GlobalConstants.appodealApiKey, types: AppodealAdType.Interstitial)
      
      // Just for creating shared instance of in-app purchase manager and to start observing transaction states
      _ = InAppPurchaseManager.sharedInstance
    }
    #endif
    
    if Settings.sharedInstance.generalHasLaunchedOnce.value == false {
      prePopulateCoreData()
      removeDisabledNotifications()
      showWelcomeWizard()
      Settings.sharedInstance.generalHasLaunchedOnce.value = true
    } else {
      if let options = launchOptions {
        if let _ = options[UIApplicationLaunchOptionsKey.localNotification] as? UILocalNotification {
          showDayViewControllerForToday()
        }
      }
    }
  }
    
  fileprivate func setupSynchronizationWithCoreData() {
    CoreDataStack.performOnPrivateContext { privateContext in
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(self.updateNotifications(_:)),
        name: NSNotification.Name.NSManagedObjectContextDidSave,
        object: privateContext)
      }
  }

  @available(iOS 9.3, *)
  fileprivate func setupHealthKitSynchronization() {
    CoreDataStack.performOnPrivateContext { privateContext in
      HealthKitProvider.sharedInstance.initSynchronizationForManagedObjectContext(privateContext)
    }
  }

  func updateNotifications(_ notification: Notification) {
    if !Settings.sharedInstance.notificationsEnabled.value {
      return
    }

    if !Settings.sharedInstance.notificationsLimit.value && !Settings.sharedInstance.notificationsSmart.value {
      return
    }

    if let insertedObjects = (notification as NSNotification).userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> {
      // Searching for the last inserted intake by date
      var lastIntakeDate: Date?
      
      for insertedObject in insertedObjects {
        if let intake = insertedObject as? Intake {
          if lastIntakeDate == nil || intake.date.isLaterThan(lastIntakeDate!) {
            lastIntakeDate = intake.date as Date
          }
        }
      }
      
      if let lastIntakeDate = lastIntakeDate , DateHelper.areEqualDays(lastIntakeDate, Date()) {
        if Settings.sharedInstance.notificationsLimit.value {
          CoreDataStack.performOnPrivateContext { privateContext in
            let beginDate = Date()
            let endDate = DateHelper.nextDayFrom(beginDate)
            
            let todayAmountParts = Intake.fetchIntakeAmountPartsGroupedBy(.day, beginDate: beginDate, endDate: endDate, dayOffsetInHours: 0,  aggregateFunction: .summary, managedObjectContext: privateContext).first!
            
            let todayWaterGoal = WaterGoal.fetchWaterGoalAmounts(beginDate: beginDate, endDate: endDate, managedObjectContext: privateContext).first!
            
            if todayAmountParts.hydration >= (todayWaterGoal + todayAmountParts.dehydration) {
              DispatchQueue.main.async {
                NotificationsHelper.removeAllNotifications()
                let nextDayDate = DateHelper.nextDayFrom(lastIntakeDate)
                NotificationsHelper.scheduleNotificationsFromSettingsForDate(nextDayDate)
              }
            } else if Settings.sharedInstance.notificationsSmart.value {
              DispatchQueue.main.async {
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

    let snapShot = window!.snapshotView(afterScreenUpdates: true)
    
    rootViewController.view.addSubview(snapShot!)
    
    window!.rootViewController = rootViewController;
    
    UIView.animate(withDuration: 0.65, animations: {
      snapShot?.layer.opacity = 0
      snapShot?.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
    }, completion: { _ in
        snapShot?.removeFromSuperview()
    })
  }
  
  fileprivate func showWelcomeWizard() {
    let storyboard = UIStoryboard(name: GlobalConstants.storyboardWelcome, bundle: nil)
    if let welcomeWizard: UIViewController = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: Constants.welcomeViewController) {
      window?.rootViewController = welcomeWizard
    }
  }
  
  fileprivate func prePopulateCoreData() {
    CoreDataStack.performOnPrivateContext { privateContext in
      if !CoreDataPrePopulation.isCoreDataPrePopulated(managedObjectContext: privateContext) {
        CoreDataPrePopulation.prePopulateCoreData(managedObjectContext: privateContext, saveContext: true)
      }
    }
  }
  
  fileprivate func removeDisabledNotifications() {
    if !Settings.sharedInstance.notificationsEnabled.value {
      NotificationsHelper.removeAllNotifications()
    }
  }
  
  func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
    NotificationsHelper.setApplicationIconBadgeNumber(0)
    
    if application.applicationState == .active {
      return
    }

    showDayViewControllerForToday()
  }
  
  func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
    NotificationsHelper.setApplicationIconBadgeNumber(0)
    showDayViewControllerForToday()
  }
  
  @available(iOS 8.0, *)
  func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
    NotificationsHelper.removeAllNotifications()
    NotificationsHelper.scheduleNotificationsFromSettingsForDate(Date())
  }
  
  fileprivate func showDayViewControllerForToday() {
    if let tabBarController = window?.rootViewController as? UITabBarController,
       let viewControllers = tabBarController.viewControllers
    {
      for (index, viewController) in viewControllers.enumerated() {
        if let dayViewController = viewController.contentViewController as? DayViewController , dayViewController.mode == .general {
          dayViewController.refreshCurrentDay(showAlert: false)
          dayViewController.switchToSelectDrinkPage()
          tabBarController.selectedIndex = index
        }
      }
    }
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NotificationsHelper.setApplicationIconBadgeNumber(0)
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // Just for getting sqlite DB folder
    //let appFolder = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    //println("App dir: \(appFolder[0])");

    NotificationsHelper.setApplicationIconBadgeNumber(0)

    refreshCurrentDayForDayViewController(showAlert: false)
  }
  
  func applicationSignificantTimeChange(_ application: UIApplication) {
    let showAlert = application.applicationState == .active
    refreshCurrentDayForDayViewController(showAlert: showAlert)
  }
  
  fileprivate func refreshCurrentDayForDayViewController(showAlert: Bool) {
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
  
  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    CoreDataStack.saveAllContexts()
    
    NotificationCenter.default.removeObserver(self)
  }
  
}

