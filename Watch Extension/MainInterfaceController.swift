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
import UserNotifications

final class MainInterfaceController: CurrentStateInterfaceController {

  // MARK: Properties
  
  override var progressImageSize: CGSize {
    return WKInterfaceDevice.currentResolution().progressImageSize
  }
  
  override var fontSizes: (title: CGFloat, upTitle: CGFloat, subTitle: CGFloat) {
    return WKInterfaceDevice.currentResolution().fontSizes
  }

  func customHandleAction(withIdentifier identifier: String?, for localNotification: UNNotification) {
    if identifier == "addIntakeAction" {
      pushController(withName: "DrinksInterfaceController", context: nil)
    }
  }
}

// MARK: WatchResolution extension

private extension WatchResolution {
  
  var progressImageSize: CGSize {
    switch self {
    case .watch38mm: return CGSize(width: 109, height: 109)
    case .watch42mm: return CGSize(width: 132, height: 132)
    case .unknown:   return CGSize(width: 132, height: 132)
    }
  }
  
  var fontSizes: (title: CGFloat, upTitle: CGFloat, subTitle: CGFloat) {
    switch self {
    case .watch38mm: return (title: 28, upTitle: 12, subTitle: 12)
    case .watch42mm: return (title: 34, upTitle: 15, subTitle: 15)
    case .unknown:   return (title: 34, upTitle: 15, subTitle: 15)
    }
  }
  
}
