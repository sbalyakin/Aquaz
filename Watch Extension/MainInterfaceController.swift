//
//  InterfaceController.swift
//  Watch Extension
//
//  Created by Sergey Balyakin on 20.10.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation
import WatchKit
import WatchConnectivity

final class MainInterfaceController: CurrentStateInterfaceController {

  // MARK: Properties
  
  override var progressImageSize: CGSize {
    return WKInterfaceDevice.currentResolution().progressImageSize
  }
  
  override var fontSizes: (title: CGFloat, upTitle: CGFloat, subTitle: CGFloat) {
    return WKInterfaceDevice.currentResolution().fontSizes
  }

  override func handleActionWithIdentifier(identifier: String?, forLocalNotification localNotification: UILocalNotification) {
    if identifier == "addIntakeAction" {
      pushControllerWithName("DrinksInterfaceController", context: nil)
    }
  }
  
  override func handleActionWithIdentifier(identifier: String?, forRemoteNotification remoteNotification: [NSObject : AnyObject]) {
    if identifier == "addIntakeAction" {
      pushControllerWithName("DrinksInterfaceController", context: nil)
    }
  }
}

// MARK: WatchResolution extension

private extension WatchResolution {
  
  var progressImageSize: CGSize {
    switch self {
    case .Watch38mm: return CGSize(width: 109, height: 109)
    case .Watch42mm: return CGSize(width: 132, height: 132)
    case .Unknown:   return CGSize(width: 132, height: 132)
    }
  }
  
  var fontSizes: (title: CGFloat, upTitle: CGFloat, subTitle: CGFloat) {
    switch self {
    case .Watch38mm: return (title: 28, upTitle: 13, subTitle: 13)
    case .Watch42mm: return (title: 34, upTitle: 16, subTitle: 16)
    case .Unknown:   return (title: 34, upTitle: 16, subTitle: 16)
    }
  }
  
}
