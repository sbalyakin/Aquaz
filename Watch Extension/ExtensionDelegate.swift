//
//  ExtensionDelegate.swift
//  Watch Extension
//
//  Created by Sergey Balyakin on 20.10.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import WatchKit
import UserNotifications

class ExtensionDelegate: NSObject, WKExtensionDelegate, UNUserNotificationCenterDelegate {
  
  override init() {
    super.init()
    
    // Initialize the connectivity provider
    ConnectivityProvider.sharedInstance.startSession()
    
    // SEB: Force russian to debug
    //UserDefaults.standard.set(["ru", "en-US"], forKey: "AppleLanguages")
    //UserDefaults.standard.synchronize()
  }
  
  func applicationDidFinishLaunching() {
    // Perform any final initialization of your application.
  }
  
  func applicationDidBecomeActive() {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillResignActive() {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, etc.
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    if let controller = WKExtension.shared().rootInterfaceController as? MainInterfaceController {
        // Call to a custom method in the root interface controller to handle the notification
      controller.customHandleAction(withIdentifier: response.actionIdentifier, for: response.notification)
      completionHandler()
    }
  }
}
